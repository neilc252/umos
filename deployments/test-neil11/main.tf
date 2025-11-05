# Terraform configuration block
# Defines required providers and configures Terraform Cloud integration.
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a suitable version constraint for the Google provider
    }
  }

  # Terraform Cloud configuration
  # Connects this workspace to a specified organization in Terraform Cloud.
  cloud {
    organization = "PremierDataMigration" # Organization name from configuration

    workspaces {
      name = "test-neil11" # Workspace name from configuration (instanceName)
    }
  }
}

# Google Cloud Platform (GCP) Provider Configuration
# Configures the Google provider with the target project and region.
provider "google" {
  project = "umos-ab24d"    # GCP Project ID from configuration
  region  = "us-central1" # Default region from configuration
}

# Resource: google_compute_instance
# Deploys a virtual machine instance on Google Cloud Platform.
resource "google_compute_instance" "this_vm" {
  name         = "test-neil11" # Instance name from configuration
  machine_type = "e2-micro"    # Machine type (VM size) from configuration
  zone         = "us-central1-a" # Derived from region; a specific zone is required for instances

  # Boot disk configuration
  # Specifies the custom image to use for the VM's boot disk.
  boot_disk {
    initialize_params {
      image   = "ubuntu-20-04-gcp-19045279782" # Custom image name as per critical instructions
      project = "umos-ab24d"                  # GCP Project ID for the custom image
    }
  }

  # Network interface configuration
  # Connects the VM to the 'default' network.
  network_interface {
    network = "default" # Use the default VPC network
    # access_config {} # Uncomment if an external IP is desired
  }

  # Deletion protection for the instance.
  # Set to false as per critical instructions.
  deletion_protection = false

  # Note: The custom script provided in the configuration is commented out
  # and instructions indicate user data scripts are not directly supported
  # for this deployment. Therefore, 'metadata_startup_script' is omitted.
}

# Output: private_ip
# Exposes the private IP address of the deployed virtual machine.
output "private_ip" {
  description = "The private IP address of the virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip # GCP specific private IP path
}