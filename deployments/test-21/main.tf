# Configure the AzureRM Provider
# CRITICAL: Configure with the subscription ID from the JSON and skip provider registration.
provider "azurerm" {
  subscription_id = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33" # Value from azure_subscription_id in the JSON config
  features {
    resource_provider {
      registration = "skip"
    }
  }
}

# CRITICAL INSTRUCTION: Use a data source to look up the existing Azure Resource Group.
# The resource group 'umos' is assumed to already exist.
data "azurerm_resource_group" "rg" {
  name = "umos" # From JSON: azure_resource_group
}

# Generate an SSH private key to be used for authentication.
# The public key will be added to the Linux Virtual Machine.
# CRITICAL INSTRUCTION: Required for Azure Linux VMs.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a Virtual Network in the existing Resource Group and Location.
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${data.azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

# Create a Subnet within the Virtual Network.
resource "azurerm_subnet" "internal" {
  name                 = "subnet-${data.azurerm_resource_group.rg.name}"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface for the Virtual Machine.
resource "azurerm_network_interface" "main" {
  name                = "nic-test-21" # Derived from JSON: platform.instanceName
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Deploy the Linux Virtual Machine.
# CRITICAL INSTRUCTION 1: Name the primary compute resource "this_vm".
resource "azurerm_linux_virtual_machine" "this_vm" {
  name                = "test-21" # From JSON: platform.instanceName
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_B1s" # From JSON: platform.vmSize
  admin_username      = "adminuser"    # Default admin username for the VM

  # CRITICAL INSTRUCTION 4: Configure SSH access using the generated key.
  # MUST use the public_key_openssh attribute.
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  # Attach the previously created network interface.
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  # Configure the OS disk for the Virtual Machine.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # CRITICAL: Use the actual cloud image name provided in the instructions.
  # The image is assumed to be a custom managed image within the specified resource group.
  source_image_id = "/subscriptions/${provider.azurerm.subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/ubuntu-20-04-19123432891"

  # CRITICAL INSTRUCTION 3: DO NOT add 'custom_data'.
  # Software installation is handled by a separate process after deployment.
  disable_password_authentication = true
}

# CRITICAL INSTRUCTION 2: Output the private IP address of the created VM.
output "private_ip" {
  description = "The private IP address of the created Virtual Machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}