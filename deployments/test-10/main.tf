# Configure Terraform Cloud for state management and remote operations
terraform {
  cloud {
    organization = "PremierDataMigration"

    workspaces {
      name = "test-10"
    }
  }

  # Specify the required providers and their versions
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Use an appropriate version constraint
    }
  }

  # Define the minimum Terraform version required
  required_version = ">= 1.0.0"
}

# Configure the Google Cloud provider
# This block sets the project and region for all GCP resources
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource block for deploying a Google Compute Engine virtual machine
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine
  name = "test-10"

  # The machine type (size) of the VM
  machine_type = "e2-micro"

  # The zone where the VM will be deployed.
  # A zone within the specified region must be chosen.
  zone = "us-central1-c"

  # Specify the project ID where the instance will be created
  project = "umos-ab24d"

  # Configure the boot disk for the VM
  boot_disk {
    initialize_params {
      # Use the custom pre-built image directly.
      # For GCP, this takes the form 'image:project/image-name' or 'image-name' if in the same project.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Configure network interfaces for the VM
  network_interface {
    # Connect the VM to the 'default' network (assuming it exists)
    network = "default"

    # Assign an external IP address (optional, remove for internal-only VM)
    # This block can be removed if public IP is not needed.
    access_config {
      // Ephemeral public IP
    }
  }

  # Enable deletion protection to prevent accidental deletion of the VM
  # Set to 'false' as per critical instruction.
  deletion_protection = false

  # Optional: User data script to be executed on first boot
  # For GCP, this is typically handled via metadata startup-script
  # For this configuration, it's noted as not directly supported for direct deployment.
  # metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
}

# Output block to expose the private IP address of the deployed virtual machine
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}