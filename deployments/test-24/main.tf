# Configure the Google Cloud provider
# Ensure you have authenticated to GCP (e.g., using `gcloud auth application-default login`)
# and set the default project if not explicitly specified in the provider block.
provider "google" {
  project = "umos-ab24d" # GCP Project ID from the configuration
  region  = "us-central1" # Region for shared resources, instances use zones
}

# Resource: Google Compute Instance (Virtual Machine)
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance, as specified in the configuration.
  name         = "test-24"
  # The machine type (e.g., n1-standard-1, e2-medium) for the VM.
  machine_type = "n1-standard-1"
  # The specific zone where the instance will be created.
  # Instances require a zone, even if the region is specified in the provider.
  # We're picking a common zone within the specified region.
  zone         = "us-central1-a"

  # Boot disk configuration for the virtual machine.
  boot_disk {
    initialize_params {
      # The custom image to use for the boot disk.
      # This image name is expected to exist within the specified GCP project.
      # Adhering to the "Actual Cloud Image Name" from the critical instructions.
      image = "ubuntu-22-04-19155927176"
    }
  }

  # Network interface configuration for the virtual machine.
  network_interface {
    # Connects the VM to the 'default' VPC network.
    # A custom network/subnet could be specified here if required for specific networking setups.
    network = "default"

    # By default, a VM without an 'access_config' block in its network interface
    # will only have an internal (private) IP address.
    # To assign an external (public) IP, an 'access_config {}' block would be added.
    # This script adheres to deploying only necessary resources and focusing on the private IP.
  }

  # Set deletion_protection to false as per the critical instructions.
  # This allows the instance to be deleted without requiring manual intervention to disable protection.
  deletion_protection = false
}

# Output block to expose the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  # For GCP, the private IP is found in the first network interface's network_ip attribute.
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}