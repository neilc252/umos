terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0" # Specify a compatible version
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0" # Specify a compatible version
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0" # Specify a compatible version
    }
  }
}

# Define input variables from the JSON configuration for clarity and reusability.
variable "azure_resource_group_name" {
  description = "The name of the existing Azure Resource Group."
  type        = string
  default     = "umos" # From JSON: azure_resource_group
}

variable "azure_subscription_id" {
  description = "The Azure Subscription ID."
  type        = string
  default     = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33" # From JSON: azure_subscription_id
}

variable "instance_name" {
  description = "The name for the virtual machine instance."
  type        = string
  default     = "test-25" # From JSON: platform.instanceName
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
  default     = "Standard_B1s" # From JSON: platform.vmSize
}

# Configure the AzureRM Provider.
# CRITICAL AZURE PROVIDER CONFIGURATION: The 'provider "azurerm"' block MUST be configured with an empty 'features' block.
provider "azurerm" {
  # Use the 'azure_subscription_id' from the JSON configuration.
  subscription_id = var.azure_subscription_id
  features {} # This must be empty, as per critical instructions.
}

# CRITICAL AZURE RESOURCE GROUP INSTRUCTION:
# The Azure Resource Group specified in the configuration ALREADY EXISTS.
# You are FORBIDDEN from creating a new one with 'resource "azurerm_resource_group"'.
# You MUST use a 'data "azurerm_resource_group"' block to look up the existing one.
# Name this data source "rg".
data "azurerm_resource_group" "rg" {
  name = var.azure_resource_group_name
}

# Generate a random suffix for resource names to ensure uniqueness across deployments.
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
  numeric = true
}

# CRITICAL AZURE LINUX VMS: You MUST generate an SSH key using a `tls_private_key` resource.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA" # Use RSA algorithm for the SSH key.
  rsa_bits  = 4096  # Set the RSA key bit length.
}

# Create a Virtual Network (VNet) for the VM.
# A VNet is essential for providing network connectivity for the virtual machine.
resource "azurerm_virtual_network" "vnet" {
  # Name the VNet using a combination of the resource group name and a unique suffix.
  name                = "${data.azurerm_resource_group.rg.name}-vnet-${random_string.suffix.result}"
  # Location inherited from the existing Resource Group.
  location            = data.azurerm_resource_group.rg.location
  # Resource Group name inherited from the existing Resource Group data source.
  resource_group_name = data.azurerm_resource_group.rg.name
  # Define the address space for the VNet.
  address_space       = ["10.0.0.0/16"]
}

# Create a Subnet within the Virtual Network.
# Virtual machines will be deployed into this subnet.
resource "azurerm_subnet" "subnet" {
  # Name the Subnet using a combination of the resource group name and a unique suffix.
  name                 = "${data.azurerm_resource_group.rg.name}-subnet-${random_string.suffix.result}"
  # Associate this subnet with the created Virtual Network.
  virtual_network_name = azurerm_virtual_network.vnet.name
  # Resource Group name inherited from the existing Resource Group data source.
  resource_group_name  = data.azurerm_resource_group.rg.name
  # Define the address prefix for the Subnet.
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a Network Interface (NIC) for the VM.
# This network interface card will connect the VM to the virtual network.
resource "azurerm_network_interface" "nic" {
  # Name the NIC using a combination of the instance name and a unique suffix.
  name                = "${var.instance_name}-nic-${random_string.suffix.result}"
  # Location inherited from the existing Resource Group.
  location            = data.azurerm_resource_group.rg.location
  # Resource Group name inherited from the existing Resource Group data source.
  resource_group_name = data.azurerm_resource_group.rg.name

  # Define the IP configuration for the NIC.
  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic" # Dynamically allocate a private IP address.
  }
}

# Deploy the Azure Linux Virtual Machine.
# CRITICAL INSTRUCTION: You MUST name the primary compute resource "this_vm".
resource "azurerm_linux_virtual_machine" "this_vm" {
  # Set the instance name from the JSON configuration.
  name                            = var.instance_name
  # Resource Group name inherited from the existing Resource Group data source.
  resource_group_name             = data.azurerm_resource_group.rg.name
  # Location inherited from the existing Resource Group data source.
  location                        = data.azurerm_resource_group.rg.location
  # Set the VM size from the JSON configuration.
  size                            = var.vm_size
  # Associate the created Network Interface with the Virtual Machine.
  network_interface_ids           = [azurerm_network_interface.nic.id]

  # Configure the OS disk for the Virtual Machine.
  os_disk {
    caching              = "ReadWrite"    # Set caching type for optimal performance.
    storage_account_type = "Standard_LRS" # Use Standard Locally Redundant Storage for the OS disk.
  }

  # CRITICAL INSTRUCTION: Admin username and SSH public key configuration.
  # The 'admin_ssh_key' block MUST use the `public_key_openssh` attribute for the public key.
  admin_username = "azureuser" # A common default admin username for Azure Linux VMs.
  admin_ssh_key {
    username   = "azureuser"
    # CRITICAL INSTRUCTION: Using `public_key_pem` is FORBIDDEN.
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  # CRITICAL INSTRUCTION: DO NOT add a 'user_data' (for AWS/GCP) or 'custom_data' (for Azure) argument.
  # Software installation is handled by a separate process after deployment.

  # IMPORTANT: This deployment uses a pre-built custom image.
  # Use the actual cloud image name: 'ubuntu-20-04-19123432891'.
  # For Azure, construct the 'source_image_id' using the subscription, resource group, and image name.
  source_image_id                 = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/ubuntu-20-04-19123432891"

  # Disable password authentication to enforce SSH key usage for enhanced security.
  disable_password_authentication = true
}

# CRITICAL INSTRUCTION: You MUST include an output block named "private_ip".
# This output exposes the private IP address of the created virtual machine.
output "private_ip" {
  # For Azure, the value should be: azurerm_linux_virtual_machine.this_vm.private_ip_address.
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
  description = "The private IP address of the created Azure Linux Virtual Machine."
}