terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0" # Specify a suitable version for the Google provider
    }
  }

  # Configure Terraform Cloud integration
  cloud {
    # The organization name in Terraform Cloud
    organization = "PremierDataMigration"

    # The workspace where this configuration will be applied
    workspaces {
      name = "test-neil8"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  # The Google Cloud project ID from the configuration
  project = "umos-ab24d"
  # The region where resources will be deployed
  region  = "us-central1"
}

# Resource block for the Google Compute Instance (Virtual Machine)
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance
  name = "test-neil8"

  # The machine type (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"

  # The zone within the region where the VM will be created.
  # For simplicity, we pick a specific zone within the specified region.
  zone = "us-central1-b"

  # Configuration for the boot disk of the VM
  boot_disk {
    initialize_params {
      # The custom image name to use for the boot disk.
      # This image is pre-built and named 'ubuntu-20-04-gcp-19045279782'
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Configuration for the network interface
  network_interface {
    # Attaches the VM to the default network.
    # Replace with a specific network name if a custom VPC network is used.
    network = "default"

    # Access config for external IP address.
    # Omit this block if no public IP is desired.
    access_config {
      # Ephemeral public IP address
    }
  }

  # Disable deletion protection to allow the instance to be deleted easily.
  # As per instructions, 'deletion_protection' is used for GCP.
  deletion_protection = false

  # The project ID where the instance will be created.
  # This explicitly sets the project for the resource, overriding provider default if necessary.
  project = "umos-ab24d"

  # A comment regarding the custom script from the input:
  # The custom script provided in the configuration indicates that user data scripts
  # are not supported for direct deployment in this context, so it is not included here.
}

# Output block to expose the private IP address of the created VM
output "private_ip" {
  description = "The private IP address of the virtual machine."
  # For GCP, the private IP is found in the first network_interface block.
  value = google_compute_instance.this_vm.network_interface[0].network_ip
}