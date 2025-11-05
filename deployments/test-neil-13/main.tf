# Terraform configuration block
terraform {
  # Configure Terraform Cloud integration for remote state management and execution
  cloud {
    organization = "PremierDataMigration" # Your Terraform Cloud organization name

    workspaces {
      name = "test-neil-13" # The specific workspace within your organization for this deployment
    }
  }

  # Define required providers and their version constraints
  required_providers {
    google = {
      source  = "hashicorp/google" # The Google Cloud Platform provider
      version = "~> 5.0"           # Recommended version constraint for stability
    }
  }
}

# Configure the Google Cloud Platform provider
# This block specifies the default project and region for all GCP resources
provider "google" {
  project = "umos-ab24d"     # The GCP Project ID where resources will be deployed
  region  = "us-central1"   # The GCP region for resource deployment
}

# Resource for deploying a Google Compute Engine virtual machine instance
resource "google_compute_instance" "this_vm" {
  name         = "test-neil-13" # The desired name for the virtual machine instance
  machine_type = "e2-micro"     # The machine type (VM size) for the instance
  zone         = "us-central1-c" # The specific zone within the region where the VM will be created

  # Configuration for the boot disk of the virtual machine
  boot_disk {
    initialize_params {
      # Specify the custom image name for the boot disk.
      # This image is pre-built and used directly.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration for the VM
  network_interface {
    network = "default" # Connects the VM to the default VPC network in the project

    # Access config to assign an ephemeral public IP address.
    # This allows the VM to be reachable from the internet.
    access_config {
      # An empty access_config block creates an ephemeral external IP address
    }
  }

  # Set deletion protection for the instance.
  # When set to `true`, the instance cannot be deleted via the API or UI.
  # Here, it's set to `false` as per the instruction.
  deletion_protection = false

  # Note: The 'customScript' provided in the configuration is explicitly
  # stated as "not yet supported for direct deployment" and is therefore
  # not included here as 'metadata_startup_script'.
}

# Output block to expose the private IP address of the created virtual machine
output "private_ip" {
  description = "The private IP address of the virtual machine."
  # GCP specific path to retrieve the private IP address from the primary network interface
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}