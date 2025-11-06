# Configure the AzureRM Provider
# The 'features' block is required for the AzureRM provider
provider "azurerm" {
  features {}
}

# Data source to retrieve current client configuration,
# specifically the subscription ID, which is needed to construct
# the custom image ID.
data "azurerm_client_config" "current" {}

# Defines an Azure Resource Group where all resources will be deployed.
# The name "umos" is taken from the JSON configuration's "azure_resource_group".
# The location "East US" is taken from "platform.region".
resource "azurerm_resource_group" "this_rg" {
  name     = "umos"
  location = "East US"
}

# Defines an Azure Virtual Network (VNet) for the virtual machine.
# This is a prerequisite for creating a network interface.
resource "azurerm_virtual_network" "this_vnet" {
  name                = "vnet-test-neil-4" # Example name derived from instance name
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name
  address_space       = ["10.0.0.0/16"]
}

# Defines a Subnet within the Virtual Network.
# Virtual machines are attached to subnets via their network interfaces.
resource "azurerm_subnet" "this_subnet" {
  name                 = "subnet-test-neil-4" # Example name derived from instance name
  resource_group_name  = azurerm_resource_group.this_rg.name
  virtual_network_name = azurerm_virtual_network.this_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Defines an Azure Network Interface (NIC) for the virtual machine.
# This NIC will be attached to the 'this_vm' resource.
resource "azurerm_network_interface" "this_nic" {
  name                = "nic-test-neil-4" # Example name derived from instance name
  location            = azurerm_resource_group.this_rg.location
  resource_group_name = azurerm_resource_group.this_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Requires the 'random' provider to generate a secure random password.
# This is used for the admin_password of the Linux virtual machine,
# as SSH keys were not provided and custom_data is disallowed.
resource "random_password" "admin_password" {
  length         = 16
  special        = true
  override_special = "!#$%&*()_-+={}[]<>,./?"
}

# Defines the Azure Linux Virtual Machine.
# CRITICAL INSTRUCTION 1: The primary compute resource MUST be named "this_vm".
resource "azurerm_linux_virtual_machine" "this_vm" {
  # VM name is taken from "platform.instanceName" in the JSON configuration.
  name                = "test-neil-4"
  # Resource group and location are referenced from the 'this_rg' resource.
  resource_group_name = azurerm_resource_group.this_rg.name
  location            = azurerm_resource_group.this_rg.location
  # VM size is taken from "platform.vmSize" in the JSON configuration.
  size                = "Standard_B1s"
  admin_username      = "azureuser" # Standard admin username for Linux VMs

  # Use the securely generated random password for SSH access.
  admin_password                = random_password.admin_password.result
  disable_password_authentication = false # Enable password authentication

  # Attach the network interface created above.
  network_interface_ids = [
    azurerm_network_interface.this_nic.id,
  ]

  # Configuration for the OS disk.
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30 # Default OS disk size
  }

  # IMPORTANT: The VM deploys from a pre-built custom image.
  # The 'Actual Cloud Image Name' from the instructions: 'ubuntu-20-04-19123432891'
  # The 'source_image_id' is constructed as a full resource ID for a custom image
  # within the specified resource group and subscription.
  source_image_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${azurerm_resource_group.this_rg.name}/providers/Microsoft.Compute/images/ubuntu-20-04-19123432891"

  # CRITICAL INSTRUCTION 3: DO NOT add 'user_data' or 'custom_data'.
  # Software installation is handled by a separate process after deployment.
}

# CRITICAL INSTRUCTION 2: Output block named "private_ip".
# Exposes the private IP address of the newly created virtual machine.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}