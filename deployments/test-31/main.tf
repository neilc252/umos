# Configure the Google Cloud provider
provider "google" {
  # Set the GCP project ID from the configuration
  project = "umos-ab24d"
  # Set the default region for regional resources
  region  = "us-central1"
}

# Resource to deploy a Google Compute Engine virtual machine
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance
  name = "test-31"

  # The GCP project ID where the instance will be deployed
  project = "umos-ab24d"

  # The zone where the VM instance will be created (e.g., us-central1-a)
  # Note: A specific zone is required for instances, derived from the provided region.
  zone = "us-central1-a"

  # The machine type for the instance (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"

  # Boot disk configuration for the VM
  boot_disk {
    # Parameters for initializing the boot disk
    initialize_params {
      # The custom image name to use for the boot disk, as specified
      image = "ubuntu-22-04-19153499615"
    }
  }

  # Network interface configuration
  network_interface {
    # Connect to the default VPC network
    network = "default"
  }

  # Set deletion protection for the instance as specified (false to allow deletion)
  deletion_protection = false

  # Note: No 'user_data' is included as per critical instructions.
  # Software installation is handled by a separate process after deployment.
}

# Output block to expose the private IP address of the deployed virtual machine
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  # Retrieve the private IP from the primary network interface
  value = google_compute_instance.this_vm.network_interface[0].network_ip
}