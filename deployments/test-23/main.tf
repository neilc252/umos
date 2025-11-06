# Configure the Azure Provider
# CRITICAL AZURE PROVIDER CONFIGURATION:
# Includes subscription_id and the required 'features' block for resource provider registration.
provider "azurerm" {
  # Use the subscription ID provided in the JSON configuration
  subscription_id = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33" # From JSON: azure_subscription_id

  features {
    resource_provider {
      # CRITICAL INSTRUCTION: Skip resource provider registration as required
      registration = "skip"
    }
  }
}

# CRITICAL AZURE RESOURCE GROUP INSTRUCTION:
# You MUST assume the Azure Resource Group already exists.
# Use a data source to reference the existing resource group.
# Name this data source "rg" as required.
data "azurerm_resource_group" "rg" {
  name = "umos" # From JSON: azure_resource_group
}

# Define a variable for the VM name for consistency and reusability.
variable "vm_name" {
  description = "The name of the Virtual Machine."
  type        = string
  default     = "test-23" # From JSON: platform.instanceName
}

# Generate an SSH private key for the Azure Linux Virtual Machine.
# CRITICAL INSTRUCTION: This resource is required for admin_ssh_key.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096 # Recommended bit length for RSA keys
}

# Create a Virtual Network (VNet) for the VM.
# This is a necessary networking resource for the VM.
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${data.azurerm_resource_group.rg.name}-tf"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location # Reference the data source for location
  resource_group_name = data.azurerm_resource_group.rg.name # Reference the data source for resource group name
}

# Create a Subnet within the Virtual Network.
# This is a necessary networking resource for the VM.
resource "azurerm_subnet" "internal" {
  name                 = "subnet-${data.azurerm_resource_group.rg.name}-tf"
  resource_group_name  = data.azurerm_resource_group.rg.name # Reference the data source
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface Card (NIC) for the Virtual Machine.
# This is a necessary networking resource for the VM.
resource "azurerm_network_interface" "main" {
  name                = "${var.vm_name}-nic-tf"
  location            = data.azurerm_resource_group.rg.location # Reference the data source
  resource_group_name = data.azurerm_resource_group.rg.name # Reference the data source

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic" # Dynamic private IP allocation
    # No public IP configuration as it's not explicitly requested and only private IP output is needed.
  }
}

# Deploy the Azure Linux Virtual Machine.
# CRITICAL INSTRUCTION 1: Name the primary compute resource "this_vm".
resource "azurerm_linux_virtual_machine" "this_vm" {
  name                = var.vm_name # Use the variable for VM name
  resource_group_name = data.azurerm_resource_group.rg.name # Reference the data source for resource group name
  location            = data.azurerm_resource_group.rg.location # Reference the data source for location
  size                = "Standard_B1s" # From JSON: platform.vmSize

  admin_username = "azureuser" # A common default admin username for Linux VMs

  # CRITICAL INSTRUCTION: For Azure Linux VMs, use tls_private_key and public_key_openssh.
  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.admin_ssh.public_key_openssh # Use the generated SSH public key
  }

  # Attach the Network Interface Card to the VM.
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Configure the OS disk.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Standard storage for general purpose VMs
  }

  # CRITICAL INSTRUCTION: Use the actual cloud image name 'ubuntu-20-04-19123432891'
  # Construct the source_image_id using the subscription ID, resource group name, and image name.
  # The instruction implies the image resides in the target resource group ("umos").
  source_image_id = format(
    "/subscriptions/%s/resourceGroups/%s/providers/Microsoft.Compute/images/%s",
    data.azurerm_resource_group.rg.subscription_id, # Get subscription ID from the data source
    data.azurerm_resource_group.rg.name,            # Get resource group name from the data source
    "ubuntu-20-04-19123432891"                      # Actual Cloud Image Name from instructions
  )

  # CRITICAL INSTRUCTION 3: DO NOT add 'custom_data' or 'user_data'.
  # Software installation is handled by a separate process after deployment.
}

# CRITICAL INSTRUCTION 2: Output block named "private_ip".
# Exposes the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the created Virtual Machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address # Value for Azure Linux VMs
}