# Terraform block to configure backend and required providers
terraform {
  # Configure Terraform Cloud backend
  cloud {
    organization = "PremierDataMigration"

    workspaces {
      name = "test-neil9"
    }
  }

  # Specify the required providers and their versions
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Use a compatible version for the Google provider
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d" # GCP Project ID from configuration
  region  = "us-central1" # GCP Region from configuration
}

# Resource to deploy a Google Compute Engine virtual machine
resource "google_compute_instance" "this_vm" {
  # Instance name from configuration
  name         = "test-neil9"
  # Machine type (VM size) from configuration
  machine_type = "e2-micro"
  # Zone for the instance, derived from the region (e.g., us-central1-c)
  # A specific zone is required; here we pick 'c' within the given region.
  zone         = "us-central1-c"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # Use the pre-built custom image name specified in the critical instructions
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # Use the default VPC network
    network = "default"

    # Access config to assign an ephemeral public IP for external access
    access_config {
      # This block can be empty to assign an ephemeral public IP
    }
  }

  # Enable deletion protection as per critical instructions
  deletion_protection = false

  # Instance metadata (optional)
  metadata = {
    # If a startup script was provided, it would go here.
    # For this configuration, it's explicitly noted as not directly supported.
  }

  # Tags (optional)
  tags = ["http-server", "https-server"]

  # Service account for the VM (optional, uses default if not specified)
  service_account {
    email  = "default"
    scopes = ["cloud-platform"]
  }
}

# Output block to expose the private IP address of the created VM
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}