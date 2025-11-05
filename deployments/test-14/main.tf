terraform {
  # Define required providers and their versions.
  # This ensures compatibility and allows Terraform to download the correct plugin.
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a compatible version range for the Google Cloud provider
    }
  }

  # Configure Terraform Cloud integration for remote state management and execution.
  cloud {
    # Specify your Terraform Cloud organization name.
    # CRITICAL: This value was not provided in the JSON configuration.
    # Please replace "<YOUR_TERRAFORM_CLOUD_ORGANIZATION>" with your actual organization name.
    organization = "<YOUR_TERRAFORM_CLOUD_ORGANIZATION>"

    # Configure the workspace where this configuration will be run.
    workspaces {
      # The workspace name is derived from the 'instanceName' in the provided configuration.
      name = "test-14"
    }
  }
}

# Configure the Google Cloud provider.
# This block specifies the project and region for resource deployment.
provider "google" {
  # The GCP project ID where resources will be deployed.
  # CRITICAL: Value taken from 'gcp_project_id' in the provided configuration.
  project = "umos-ab24d"

  # The region where the virtual machine will be provisioned.
  # Value taken from 'platform.region' in the provided configuration.
  region = "us-central1"
}

# Resource block to define the Google Compute Engine virtual machine.
# CRITICAL: The resource is named "this_vm" as per instructions.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance.
  # Value taken from 'platform.instanceName' in the provided configuration.
  name = "test-14"

  # The machine type (VM size) for the instance.
  # Value taken from 'platform.vmSize' in the provided configuration.
  machine_type = "e2-micro"

  # The zone within the specified region where the instance will be created.
  # A specific zone was not provided, so 'us-central1-a' is chosen as a default within the 'us-central1' region.
  zone = "us-central1-a"

  # Configuration for the boot disk of the virtual machine.
  boot_disk {
    initialize_params {
      # The custom image to use for the boot disk.
      # IMPORTANT: This uses the 'os.name' value ('ubuntu-20-04-gcp-19045279782')
      # as specified in the critical instructions for pre-built custom images,
      # overriding 'platform.osImageId' if it were different.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration for the VM.
  # It connects the VM to the 'default' network.
  network_interface {
    network = "default" # Assumes the default VPC network exists.
    # To assign a public IP, an 'access_config {}' block would be added here.
    # It's omitted as the request focuses on the private IP output.
  }

  # CRITICAL: Set deletion protection to 'false' as required.
  # This prevents accidental deletion of the instance.
  deletion_protection = false

  # User data (customScript) is mentioned as not directly supported in the JSON.
  # Therefore, 'metadata_startup_script' or similar is not included.
}

# Output block to expose the private IP address of the created VM.
# CRITICAL: Named "private_ip" as per instructions.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  # For GCP, the private IP is found in the first network interface's 'network_ip'.
  value = google_compute_instance.this_vm.network_interface[0].network_ip
}