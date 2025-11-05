terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a suitable version constraint for the Google provider
    }
  }

  cloud {
    # Configure Terraform Cloud integration
    organization = "PremierDataMigration"

    workspaces {
      # Link to a specific Terraform Cloud workspace
      name = "test-neil6"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  # The GCP project ID where resources will be deployed
  project = "umos-ab24d"
  # The default region for resource deployment
  region  = "us-central1"
  # Authentication is typically handled by environment variables (e.g., GOOGLE_APPLICATION_CREDENTIALS)
  # or Terraform Cloud's workload identity for GCP.
}

# Resource block for the Google Compute Instance
resource "google_compute_instance" "this_vm" {
  # Name of the virtual machine
  name         = "test-neil6"
  # Machine type (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"
  # The specific zone within the region where the VM will be created
  zone         = "us-central1-a" # A common zone for 'us-central1'

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # CRITICAL: Use the pre-built custom image name as specified in the instructions
      image = "ubuntu-20-04-gcp-19045279782"
      # If the image was from a different project, 'project' would be specified here:
      # project = "other-gcp-project-id"
    }
  }

  # Network interface configuration
  network_interface {
    # Connects to the default VPC network in the project
    network = "default"

    # Assign an ephemeral public IP address to the instance
    access_config {
      # An empty access_config block creates an ephemeral public IP.
      # To create a static external IP, an `google_compute_address` resource would be needed.
    }
  }

  # Metadata startup script for initial configuration when the VM boots
  # The script provided in the configuration will be executed on first boot.
  metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # CRITICAL: Set deletion_protection to false as per instructions.
  # This prevents accidental deletion of the instance. Set to true to enable protection.
  deletion_protection = false

  # Labels for better resource organization and management
  labels = {
    environment = "dev"
    created_by  = "terraform"
    instance_name = "test-neil6"
  }

  # Shielded VM configuration for enhanced security
  shielded_instance_config {
    enable_integrity_monitoring = true
    enable_secure_boot          = false # Often disabled for custom images or specific configurations
    enable_vtpm                 = true
  }

  # Service account attached to the VM for authorization to GCP services
  service_account {
    email  = "default" # Uses the default Compute Engine service account
    scopes = ["cloud-platform"] # Grants broad access; consider least privilege for production
  }

  # Network tags for applying firewall rules
  tags = ["http-server", "https-server"]
}

# Output block to expose the private IP address of the virtual machine
output "private_ip" {
  description = "The private IP address of the created Google Compute Instance."
  # CRITICAL: Specific value path for GCP private IP
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}