terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource for a Google Compute Engine virtual machine instance
resource "google_compute_instance" "vm_instance" {
  # The name of the virtual machine instance
  name = "test-neil2"

  # The machine type (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"

  # The zone where the VM will be deployed.
  # For instances, a specific zone is required, not just a region.
  zone = "us-central1-a"

  # Set the project ID for this resource explicitly
  project = "umos-ab24d"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # Custom image name for the boot disk.
      # This image is expected to be available in the specified project.
      image = "ubuntu-20.04-gcp-1762194682673"
    }
  }

  # Network interface configuration
  network_interface {
    # Connect to the 'default' VPC network
    network = "default"

    # Access configuration to assign an external IP address
    access_config {
      # No parameters needed for default external IP
    }
  }

  # Prevent accidental deletion of the instance.
  # Set to 'false' as per requirements for this deployment.
  deletion_protection = false

  # Metadata startup script.
  # The original configuration noted "User data scripts are not yet supported for direct deployment."
  # For GCP, startup scripts are passed via metadata.
  # If a script were to be used, it would look like this:
  # metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
  # Since the original customScript indicated it's not directly supported, we'll omit it for a clean deployment.

  # Service account to grant permissions to the VM.
  # Recommended to specify a service account with minimal necessary permissions.
  # For basic testing, the default compute engine service account is often used.
  service_account {
    email  = "default" # Uses the default Compute Engine service account
    scopes = ["cloud-platform"] # Grants broad access, refine for production
  }

  # Tags for network firewall rules, etc.
  tags = ["http-server", "https-server"]
}