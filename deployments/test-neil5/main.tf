# Configure Terraform Cloud for state management and remote operations
terraform {
  # Define required providers and their versions
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a compatible version range for the Google provider
    }
  }

  # Configure Terraform Cloud integration
  cloud {
    organization = "PremierDataMigration" # Terraform Cloud organization name

    # Define the workspace to use within the organization
    workspaces {
      name = "test-neil5" # Terraform Cloud workspace name
    }
  }
}

# Configure the Google Cloud Platform provider
# The 'project' and 'region' are essential for deploying resources to GCP.
provider "google" {
  project = "umos-ab24d"    # Your GCP project ID
  region  = "us-central1" # The default region for resource deployment
}

# Resource block to create a Google Compute Engine virtual machine instance
resource "google_compute_instance" "this_vm" {
  name         = "test-neil5"  # Name of the virtual machine instance
  machine_type = "e2-micro"      # Machine type (size) of the VM
  zone         = "us-central1-a" # Zone where the VM will be deployed (derived from region)

  # Configure the boot disk for the VM
  boot_disk {
    initialize_params {
      # Use the custom image name provided in the configuration
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Configure network interfaces for the VM
  network_interface {
    network = "default" # Use the default VPC network

    # Access config to assign an ephemeral public IP address
    # Remove this block if only private IP access is desired
    access_config {}
  }

  # Apply a startup script to the VM
  metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # Critical instruction: Disable deletion protection
  deletion_protection = false

  # Optional: Tags can be used for network firewall rules, load balancers, etc.
  # tags = ["web-server", "http-server"]
}

# Output block to expose the private IP address of the created VM
# This value can be easily retrieved after deployment using 'terraform output'
output "private_ip" {
  description = "The private IP address of the virtual machine."
  # For GCP, the private IP is found within the network_interface block
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}