terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0" # Specify a suitable version constraint for the Google provider
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  # The GCP project ID where resources will be deployed
  project = "umos-ab24d"
  # The region for resource deployment
  region  = "us-central1"
}

# Resource block for the Google Compute Instance
resource "google_compute_instance" "this_vm" {
  # Name of the virtual machine instance
  name         = "test-neil8"
  # Zone where the VM will be deployed. Picked a default zone within the specified region.
  zone         = "us-central1-a"
  # Machine type (VM size) for the instance
  machine_type = "e2-micro"
  # Explicitly set the project ID for the instance, as per instructions
  project      = "umos-ab24d"

  # Boot disk configuration for the VM
  boot_disk {
    initialize_params {
      # Specifies the custom image to be used for the boot disk
      # This image name comes directly from the configuration's 'os.name'
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # Uses the default VPC network
    network = "default"
    # To assign an ephemeral public IP, uncomment the following block:
    # access_config {
    #   # An empty access_config block assigns an ephemeral external IP address
    # }
  }

  # Set deletion protection to false, as per critical instructions
  # This allows the instance to be deleted via Terraform
  deletion_protection = false

  # The customScript from the configuration indicates user data scripts are not
  # directly supported for this type of deployment. If it were a real script,
  # it would typically be passed via `metadata_startup_script`.
  # metadata_startup_script = "#!/bin/bash\necho 'Hello from startup script!'"
}

# Output block to expose the private IP address of the created virtual machine
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  # Accesses the private IP from the first network interface of the VM
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}