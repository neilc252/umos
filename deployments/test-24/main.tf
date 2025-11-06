# Configure the AzureRM Provider
# The 'features' block must be empty as per critical instructions to avoid deprecation warnings.
provider "azurerm" {
  subscription_id = var.azure_subscription_id
  features {}
}

# Data source to reference the existing Azure Resource Group.
# The resource group is assumed to already exist and will not be created by Terraform.
# This data source is named "rg" as per critical instructions.
data "azurerm_resource_group" "rg" {
  name = var.azure_resource_group_name
}

# Generates an SSH private key that will be used for administrative access to the Linux VM.
# The public key derived from this will be configured on the VM.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Creates a Virtual Network (VNet) for the VM.
# This provides network isolation and a private IP address space.
resource "azurerm_virtual_network" "main" {
  name                = "${var.instance_name}-vnet"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"] # A common address space for a new VNet
}

# Creates a subnet within the Virtual Network.
# VMs will be deployed into this subnet.
resource "azurerm_subnet" "internal" {
  name                 = "${var.instance_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"] # A common address prefix for a subnet
}

# Creates a Network Interface (NIC) for the VM.
# This connects the VM to the subnet and assigns it an IP configuration.
resource "azurerm_network_interface" "main" {
  name                = "${var.instance_name}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic" # Assigns a private IP dynamically
  }
}

# Deploys the Azure Linux Virtual Machine.
# This resource is named "this_vm" as per critical instructions.
resource "azurerm_linux_virtual_machine" "this_vm" {
  name                = var.instance_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = "azureuser" # Standard admin username for Azure Linux VMs

  # Connects the VM to the created Network Interface.
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Configures SSH administrative access using the generated SSH key.
  # Critically uses `public_key_openssh` from the tls_private_key resource, not `public_key_pem`.
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  # Defines the OS disk configuration for the VM.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30 # Default disk size for the OS disk
  }

  # Specifies the source image for the VM.
  # This uses a custom image identified by its full Azure Resource ID path.
  source_image_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/${var.os_image_name}"

  # Boot diagnostics are disabled as per "necessary resources only" instruction.
  boot_diagnostics {
    enabled = false
  }

  # User data/custom data is explicitly excluded as per critical instructions.
}

# Defines input variables for the Terraform configuration.
variable "instance_name" {
  description = "The name of the virtual machine instance."
  type        = string
  default     = "test-24" # Value from JSON configuration
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
  default     = "Standard_B1s" # Value from JSON configuration
}

variable "azure_resource_group_name" {
  description = "The name of the existing Azure Resource Group where resources will be deployed."
  type        = string
  default     = "umos" # Value from JSON configuration
}

variable "azure_subscription_id" {
  description = "The Azure Subscription ID where the resources will be deployed."
  type        = string
  default     = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33" # Value from JSON configuration
}

variable "os_image_name" {
  description = "The name of the custom OS image to use for the virtual machine."
  type        = string
  default     = "ubuntu-20-04-19123432891" # Actual cloud image name from instructions
}

# Output block for the private IP address of the deployed virtual machine.
# This output is named "private_ip" as per critical instructions.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}