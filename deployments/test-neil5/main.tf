# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource to deploy the virtual machine
resource "google_compute_instance" "this_vm" {
  # VM instance name
  name = "test-neil5"
  # Machine type (VM size)
  machine_type = "e2-micro"
  # Zone where the VM will be deployed. Choosing 'a' in the specified region.
  zone = "us-central1-a"
  # GCP project ID
  project = "umos-ab24d"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # Custom image name for the boot disk
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # Using the default VPC network for simplicity
    network = "default"

    # Access config to assign an ephemeral external IP address
    access_config {
      # An empty block assigns an ephemeral external IP
    }
  }

  # Set deletion protection to false as specified
  deletion_protection = false

  # Optional: Metadata for the instance, can be used for startup scripts, etc.
  # metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment."
}

# Output block to expose the private IP address of the virtual machine
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}