# Configure the Azure Resource Manager Provider
# Ensure you have logged in to Azure CLI (`az login`) or set environment variables
# for authentication.
provider "azurerm" {
  features {}
}

# Retrieve the current Azure client configuration (e.g., subscription ID)
data "azurerm_client_config" "current" {}

# Define a variable for the virtual machine name for easy reuse
variable "instance_name" {
  description = "The name of the virtual machine."
  type        = string
  default     = "test-neil-15" # From platform.instanceName
}

# Define a variable for the Azure region
variable "azure_region" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "East US" # From platform.region
}

# Define a variable for the Azure resource group name
variable "azure_resource_group_name" {
  description = "The name of the Azure resource group."
  type        = string
  default     = "umos" # From azure_resource_group
}

# Create an Azure Resource Group to organize all related resources
resource "azurerm_resource_group" "main" {
  name     = var.azure_resource_group_name
  location = var.azure_region
}

# Create a Virtual Network for the VM
resource "azurerm_virtual_network" "main" {
  name                = "${var.instance_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "internal" {
  name                 = "${var.instance_name}-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface for the Virtual Machine
resource "azurerm_network_interface" "main" {
  name                = "${var.instance_name}-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Deploy the Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "this_vm" {
  # CRITICAL INSTRUCTION 1: Name the primary compute resource "this_vm"
  name                = var.instance_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s" # From platform.vmSize
  admin_username      = "azureuser"    # Default admin username for the VM

  # Attach the network interface created above
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Configure the OS disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # IMPORTANT: Use the specified custom image name to construct the source_image_id.
  # This assumes the custom image 'ubuntu-20-04-19123432891' exists in the same resource group ('umos')
  # and subscription as where the VM is being deployed.
  source_image_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.main.name}/providers/Microsoft.Compute/images/ubuntu-20-04-19123432891"

  # SSH public key for administrator access to the Linux VM.
  # Replace the `public_key` with your actual SSH public key content.
  admin_ssh_key {
    username   = "azureuser"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC8Z+...your_actual_public_key...Q/Lg3X root@hostname"
  }

  # CRITICAL INSTRUCTION 3: DO NOT add 'custom_data' or 'user_data'.
  # Software installation is handled by a separate process after deployment.
}

# CRITICAL INSTRUCTION 2: Output block named "private_ip"
# Exposes the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}