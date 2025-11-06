# Configure the Google Cloud provider
# This block specifies the project and region where resources will be deployed.
provider "google" {
  project = "umos-ab24d"       # GCP project ID from configuration
  region  = "us-central1"     # GCP region from configuration
}

# Resource: Google Compute Engine Virtual Machine
# Deploys a virtual machine instance named "this_vm" on Google Cloud Platform.
resource "google_compute_instance" "this_vm" {
  name         = "test-neil28"       # Name of the virtual machine instance
  machine_type = "e2-micro"          # Instance type/size from configuration
  zone         = "us-central1-a"     # Default zone within the specified region

  # Configure the boot disk for the VM.
  # This section specifies the image to be used for the VM's primary disk.
  boot_disk {
    initialize_params {
      # Use the exact custom image name provided for deployment.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Configure network interfaces for the VM.
  # This VM will be connected to the 'default' VPC network.
  network_interface {
    network = "default" # Connects to the default VPC network
  }

  # Set deletion protection for the VM instance.
  # As per instructions, deletion_protection is set to false.
  deletion_protection = false
}

# Output: Private IP Address of the Virtual Machine
# This output block exposes the internal IP address of the deployed VM.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}