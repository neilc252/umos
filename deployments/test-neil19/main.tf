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
provider "azurerm" {
  features {} # Required for recent azurerm provider versions
}

# Data source to retrieve the current Azure subscription ID
data "azurerm_subscription" "current" {}

# --- Input Variables ---
# Define variables to make the script more flexible and configurable

variable "resource_group_name" {
  description = "The name of the Azure Resource Group to deploy resources into."
  type        = string
  default     = "umos" # Value from JSON: azure_resource_group
}

variable "location" {
  description = "The Azure region where the virtual machine and related resources will be deployed."
  type        = string
  default     = "East US" # Value from JSON: platform.region
}

variable "vm_name" {
  description = "The name for the virtual machine."
  type        = string
  default     = "test-neil19" # Value from JSON: platform.instanceName
}

variable "vm_size" {
  description = "The size of the virtual machine (e.g., Standard_B1s)."
  type        = string
  default     = "Standard_B1s" # Value from JSON: platform.vmSize
}

variable "admin_username" {
  description = "The administrative username for the virtual machine."
  type        = string
  default     = "adminuser" # A common default for Linux VMs
}

# --- Networking Resources ---
# These resources are necessary to provide network connectivity for the VM

# Create a Virtual Network (VNet) for the VM
resource "azurerm_virtual_network" "main" {
  name                = "${var.vm_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.resource_group_name
}

# Create a Subnet within the VNet
resource "azurerm_subnet" "internal" {
  name                 = "${var.vm_name}-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface (NIC) for the VM
resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# --- SSH Key Generation ---
# Required for Azure Linux VMs for secure administration.

# Generate a new SSH private key using the TLS provider
# This key will be used to connect to the Linux VM securely.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# --- Virtual Machine Resource ---
# Defines the Azure Linux Virtual Machine itself

resource "azurerm_linux_virtual_machine" "this_vm" {
  # CRITICAL INSTRUCTION 1: Primary compute resource MUST be named "this_vm"
  name                = var.vm_name
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username

  # Disable password authentication to enforce SSH key usage for security
  disable_password_authentication = true

  # Attach the previously created network interface to the VM
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Configure the OS disk for the virtual machine
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Configure the source image for the VM
  # IMPORTANT: Uses the 'Actual Cloud Image Name' from critical instructions: 'ubuntu-20-04-19123432891'
  # The source_image_id is constructed using the current subscription ID and the specified resource group.
  source_image_id = "/subscriptions/${data.azurerm_subscription.current.id}/resourceGroups/${var.resource_group_name}/providers/Microsoft.Compute/images/ubuntu-20-04-19123432891"

  # Configure the administrative SSH key for the VM
  # CRITICAL INSTRUCTION 4: Must use tls_private_key.admin_ssh.public_key_openssh
  admin_ssh_key {
    username   = var.admin_username
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  # CRITICAL INSTRUCTION 3: DO NOT add 'custom_data' or 'user_data' arguments.
  # Software installation is handled by a separate process after deployment.
}

# --- Outputs ---
# Define outputs to expose useful information about the deployed resources

# CRITICAL INSTRUCTION 2: Output the private IP address of the created VM
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}

# Output the generated SSH private key for connecting to the VM
# Marked as sensitive to prevent it from being displayed in plaintext in logs
output "ssh_private_key" {
  description = "The generated SSH private key for connecting to the VM."
  value       = tls_private_key.admin_ssh.private_key_openssh
  sensitive   = true
}