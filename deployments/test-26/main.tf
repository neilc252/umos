terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# Configure the AzureRM Provider
# CRITICAL: `skip_provider_registration` is explicitly set to true as per instructions
# to prevent permissions errors in the CI/CD environment.
provider "azurerm" {
  subscription_id        = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33"
  skip_provider_registration = true
  features {}
}

# --- Data Sources ---

# CRITICAL: Look up the existing Azure Resource Group.
# The resource group 'umos' is assumed to already exist and will not be created.
data "azurerm_resource_group" "rg" {
  name = "umos"
}

# --- Resources ---

# Generate an SSH private key for the Azure Linux Virtual Machine.
# This key will be used for administrative access to the VM.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a Virtual Network for the VM.
# The name includes the resource group name for uniqueness within the subscription.
resource "azurerm_virtual_network" "vnet" {
  name                = "${data.azurerm_resource_group.rg.name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create a Subnet within the Virtual Network.
resource "azurerm_subnet" "subnet" {
  name                 = "${data.azurerm_resource_group.rg.name}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface for the VM.
# This interface will connect the VM to the subnet.
resource "azurerm_network_interface" "nic" {
  name                = "test-26-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# CRITICAL: Deploy the Azure Linux Virtual Machine.
# The resource name MUST be "this_vm" as per instructions.
resource "azurerm_linux_virtual_machine" "this_vm" {
  name                            = "test-26"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  disable_password_authentication = true # Using SSH key for authentication

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # CRITICAL: Configure the SSH admin key using the `tls_private_key` resource.
  # The `public_key_openssh` attribute MUST be used.
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30 # Default disk size, not specified in config
  }

  # CRITICAL: Use the specified custom image name to construct the source_image_id.
  # Format for a custom managed image: /subscriptions/{subscription_id}/resourceGroups/{resource_group_name}/providers/Microsoft.Compute/images/{image_name}
  source_image_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/ubuntu-20-04-19123432891"

  # No `custom_data` or `user_data` argument as per instructions.
}

# --- Variables ---

# Variable for Azure Subscription ID for clarity and reusability
variable "azure_subscription_id" {
  description = "The Azure Subscription ID where resources will be deployed."
  type        = string
  default     = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33"
}

# --- Outputs ---

# CRITICAL: Output the private IP address of the created virtual machine.
# The output name MUST be "private_ip".
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}

# Output the generated SSH private key for administrative access
output "ssh_private_key" {
  description = "The private key for SSH access to the VM. Keep this secure!"
  value       = tls_private_key.admin_ssh.private_key_pem
  sensitive   = true
}