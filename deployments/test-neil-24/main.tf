# Configure the Azure Provider
provider "azurerm" {
  # Use the subscription ID provided in the configuration
  subscription_id = var.azure_subscription_id

  # CRITICAL: Disable automatic resource provider registration as per instructions.
  # This is required for the CI/CD environment and prevents permissions errors.
  skip_provider_registration = true
  features {}
}

# Look up the existing Azure Resource Group by name
# CRITICAL: Do NOT create a new resource group. This data source references an existing one.
data "azurerm_resource_group" "rg" {
  name = var.azure_resource_group # Using the 'azure_resource_group' from the JSON config
}

# Generate an SSH key for administrative access to the Linux VM
# CRITICAL: Required for Azure Linux VMs. The public key will be used in the VM's admin_ssh_key block.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create a Virtual Network for the VM
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.instance_name}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    environment = "dev"
  }
}

# Create a Subnet within the Virtual Network
resource "azurerm_subnet" "subnet" {
  name                 = "${var.instance_name}-subnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a Network Interface for the VM
resource "azurerm_network_interface" "nic" {
  name                = "${var.instance_name}-nic"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    environment = "dev"
  }
}

# Deploy the Azure Linux Virtual Machine
# CRITICAL: The primary compute resource MUST be named "this_vm".
resource "azurerm_linux_virtual_machine" "this_vm" {
  name                = var.instance_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = "adminuser" # Standard admin username for Linux VMs
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # CRITICAL: Configure SSH access using the generated public key.
  # The 'public_key' attribute MUST use 'tls_private_key.admin_ssh.public_key_openssh'.
  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.admin_ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30 # Default OS disk size
  }

  # CRITICAL: Use the actual cloud image name 'ubuntu-22-04-19149240272' to construct the source_image_id.
  # This assumes the custom image is a Managed Image within the specified resource group and subscription.
  source_image_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${data.azurerm_resource_group.rg.name}/providers/Microsoft.Compute/images/ubuntu-22-04-19149240272"

  # CRITICAL: User data scripts (custom_data) are explicitly forbidden as per instructions.
  # Do not add a 'custom_data' argument to this resource.

  # CRITICAL: The 'enabled' argument is forbidden for azurerm_linux_virtual_machine.

  tags = {
    environment = "dev"
  }
}

# Output the private IP address of the created virtual machine
# CRITICAL: The output block MUST be named "private_ip".
output "private_ip" {
  description = "The private IP address of the virtual machine."
  value       = azurerm_linux_virtual_machine.this_vm.private_ip_address
}

# Define variables for configuration values from the JSON input
variable "instance_name" {
  description = "The name of the virtual machine instance."
  type        = string
  default     = "test-neil-24" # From platform.instanceName
}

variable "vm_size" {
  description = "The size of the virtual machine."
  type        = string
  default     = "Standard_B1s" # From platform.vmSize
}

variable "azure_resource_group" {
  description = "The name of the existing Azure Resource Group."
  type        = string
  default     = "umos" # From azure_resource_group
}

variable "azure_subscription_id" {
  description = "The Azure subscription ID."
  type        = string
  default     = "c0ddf8f4-14b2-432e-b2fc-dd8456adda33" # From azure_subscription_id
}