# Configure the Google Cloud provider
# The project and region can be set here, and will be inherited by resources
# unless overridden explicitly at the resource level.
provider "google" {
  project = "umos-ab24d" # Retrieved from gcp_project_id in the configuration
  region  = "us-central1" # Retrieved from platform.region in the configuration
}

# Resource: google_compute_instance
# Deploys a Google Compute Engine virtual machine instance.
resource "google_compute_instance" "this_vm" {
  # CRITICAL INSTRUCTION: Name the primary compute resource "this_vm"
  # This resource creates the virtual machine instance.

  # Project ID for the instance. Explicitly set as per instructions.
  project = "umos-ab24d" # Retrieved from gcp_project_id in the configuration

  # Name of the virtual machine instance.
  name = "test-console" # Retrieved from platform.instanceName in the configuration

  # Machine type specifies the number of virtual CPUs and memory.
  machine_type = "e2-micro" # Retrieved from platform.vmSize in the configuration

  # Zone where the VM instance will be created.
  # For simplicity, we choose a specific zone within the specified region.
  zone = "us-central1-a"

  # Boot disk configuration for the VM.
  boot_disk {
    initialize_params {
      # CRITICAL INSTRUCTION: Use the actual cloud image name provided.
      # This image is used to create the VM's boot disk.
      image = "ubuntu-20-04-19045279782" # Explicitly provided "Actual Cloud Image Name"
    }
  }

  # Network interface configuration.
  # This block defines how the VM connects to the network.
  network_interface {
    # Connects the VM to the default VPC network.
    network = "default"

    # Access configuration block.
    # An empty access_config block assigns an ephemeral external IP address to the VM.
    # If this block is omitted, the VM will only have a private IP.
    access_config {
    }
  }

  # CRITICAL INSTRUCTION: Set deletion_protection to false.
  # This prevents accidental deletion of the instance. Set to false as requested.
  deletion_protection = false

  # CRITICAL INSTRUCTION: No 'user_data' or 'custom_data' argument.
  # Software installation is handled by a separate process after deployment.
}

# Output Block: private_ip
# CRITICAL INSTRUCTION: Expose the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  # CRITICAL INSTRUCTION: For GCP, the value should be google_compute_instance.this_vm.network_interface[0].network_ip
  value = google_compute_instance.this_vm.network_interface[0].network_ip
}