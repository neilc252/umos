terraform {
  # Configure Terraform Cloud integration for remote state and execution.
  cloud {
    # Specifies the Terraform Cloud organization.
    organization = "PremierDataMigration"

    # Defines the workspace within the organization for this project.
    workspaces {
      name = "test-neil10"
    }
  }

  # Declare the required providers and their versions.
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a compatible version for the Google provider.
    }
  }
}

# Configure the Google Cloud provider.
# This block sets up the default project and region for all Google Cloud resources.
provider "google" {
  project = "umos-ab24d"    # Your GCP project ID where resources will be deployed.
  region  = "us-central1" # The default region for resources if not specified elsewhere.
}

# Resource block to deploy a Google Compute Engine Virtual Machine instance.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance.
  name         = "test-neil10"
  # The machine type (e.g., CPU, memory) for the VM.
  machine_type = "e2-micro"
  # The specific zone within the region where the instance will be created.
  # A zone is required for google_compute_instance.
  zone         = "us-central1-b" # Using a specific zone within the 'us-central1' region.

  # Boot disk configuration for the VM.
  boot_disk {
    initialize_params {
      # Specifies the custom pre-built image to use for the boot disk.
      # This uses the image name provided in the configuration.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration for the VM.
  network_interface {
    # Connects the VM to the specified VPC network (e.g., "default" network).
    network = "default"

    # Configuration for external access.
    # An empty access_config block assigns an ephemeral public IP address.
    access_config {
      # Ephemeral public IP will be assigned.
    }
  }

  # Critical instruction: Set deletion protection to false.
  # This allows the VM to be deleted easily via Terraform.
  deletion_protection = false

  # Note: The 'customScript' from the JSON configuration is not directly
  # applied here as the instructions state "User data scripts are not yet
  # supported for direct deployment" in the provided configuration.
}

# Output block to expose the private IP address of the created VM.
# This makes the private IP easily accessible after deployment, for example,
# for SSH connections within the network.
output "private_ip" {
  description = "The private IP address of the virtual machine."
  # Retrieves the private IP from the first network interface of the created VM.
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}