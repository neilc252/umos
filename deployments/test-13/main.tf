terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  cloud {
    # CRITICAL: Replace "my-terraform-cloud-organization" with your actual Terraform Cloud organization name.
    # The 'terraform_cloud_organization' value was not provided in the input JSON configuration.
    organization = "my-terraform-cloud-organization"

    workspaces {
      name = "test-13" # From platform.instanceName
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d"      # From gcp_project_id
  region  = "us-central1"    # From platform.region
}

# Resource for the Google Compute Instance
resource "google_compute_instance" "this_vm" {
  name         = "test-13"       # From platform.instanceName
  machine_type = "e2-micro"      # From platform.vmSize
  zone         = "us-central1-a" # Using a default zone within the specified region

  # Configure the boot disk for the VM
  boot_disk {
    initialize_params {
      # CRITICAL: Using the pre-built custom image name directly as specified.
      # The project context for resolving this image comes from the provider configuration.
      image = "ubuntu-20-04-gcp-19045279782" # From os.name
    }
  }

  # Configure network interface
  network_interface {
    network = "default" # Attaches the VM to the 'default' network
  }

  # CRITICAL: Set deletion_protection to false as required.
  deletion_protection = false

  # Note: The 'customScript' from the configuration is not used here as
  # the provided configuration states "User data scripts are not yet supported for direct deployment."
}

# Output the private IP address of the created virtual machine
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}