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

# Configure the Azure provider
# CRITICAL: skip_provider_registration = true as per instructions
provider "azurerm" {
  features {}
  skip_provider_registration = true
}

# Configure the TLS provider for generating SSH keys
provider "tls" {}

# Data source to retrieve current Azure client configuration,
# specifically to get the subscription ID needed for custom image resource ID construction.
data "azurerm_client_config" "current" {}

# Define local variables for easy configuration and readability
locals {
  vm_name             = "test-neil20"
  location            = "eastus" # Azure regions are typically lowercase
  vm_size             = "Standard_B1s"
  resource_group_name = "umos"
  admin_username      = "adminuser"                                 # Admin username for the VM, as per instruction example
  image_name          = "ubuntu-20-04-19123432891"                  # Actual Cloud Image Name from instructions
}

# Create an Azure Resource Group to contain all resources
resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

# Create a Virtual Network for the VM
resource "azurerm_virtual_network" "vnet" {
  name                = "${local.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "${local.vm_name}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface for the Virtual Machine
resource "azurerm_network_interface" "nic" {
  name                = "${local.vm_name}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Generate an SSH private key for the admin user.
# CRITICAL: This resource is required for Azure Linux VMs.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Deploy the Azure Linux Virtual Machine
# CRITICAL: The primary compute resource MUST be named "this_vm"
resource "azurerm_linux_virtual_machine" "this_vm" {
  name                = local.vm_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = local.vm_size
  admin_username      = local.admin_username
  # It is best practice to disable password authentication when using SSH keys
  disable_password_authentication = true

  # Associate the Network Interface with the VM
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # OS Disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Custom image definition based on the provided image name.
  # CRITICAL: The source_image_id is constructed using the subscription ID from the client config,
  # the resource group name, and the specified custom image name.
  source_image_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/${local.image_name}"

  # SSH Key configuration for the admin user.
  # CRITICAL: public_key_openssh attribute MUST be used for the public_key.
  admin_ssh_key {
    username   = local.admin_username
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  tags = {
    Environment = "Dev"
    Project     = "TerraformVM"
  }
}

# Output the private IP address of the created virtual machine
# CRITICAL: Output block MUST be named "private_ip" and use the correct attribute.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}