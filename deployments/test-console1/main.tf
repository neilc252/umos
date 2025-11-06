# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d" # GCP project ID from the configuration
  region  = "us-central1" # Default region for resources
}

# Resource: Google Compute Instance
# Deploys a virtual machine instance on Google Cloud Platform.
resource "google_compute_instance" "this_vm" {
  name         = "test-console1" # Name of the virtual machine instance
  machine_type = "e2-micro"      # Machine type (VM size)
  zone         = "us-central1-a" # Zone where the instance will be deployed. Picked a common zone within the specified region.
  project      = "umos-ab24d"    # Explicitly set the project ID for the instance.

  # Boot Disk Configuration
  boot_disk {
    initialize_params {
      # Use the specific custom image name provided in the prompt.
      # This image is assumed to exist within the specified project.
      image = "ubuntu-20-04-19045279782"
    }
  }

  # Network Interface Configuration
  # Configures the network connectivity for the VM.
  # Assumes the 'default' network exists in the project.
  network_interface {
    network = "default" # Connects the VM to the 'default' VPC network.

    # Access config allows external IP address.
    # If not needed, remove this block for an internal-only VM.
    access_config {
      # This block can be empty to assign an ephemeral public IP.
    }
  }

  # Set deletion protection to false as specified.
  deletion_protection = false

  # Tags (optional): can be used for network firewall rules
  # tags = ["web", "http"]
}

# Output: Private IP Address
# Exposes the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}