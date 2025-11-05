terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  cloud {
    organization = "PremierDataMigration"

    workspaces {
      name = "test-neil12"
    }
  }
}

provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

resource "google_compute_instance" "this_vm" {
  name         = "test-neil12"
  machine_type = "e2-micro"
  zone         = "us-central1-a" # Using a default zone within the specified region

  # Configure the boot disk
  boot_disk {
    initialize_params {
      # Use the pre-built custom image directly as specified
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Configure network interface
  network_interface {
    network = "default" # Assumes a 'default' network exists in the project
    access_config {
      # This block allows the VM to have an external IP address.
      # Remove if only internal IP is desired or managed by other resources.
    }
  }

  # Project ID for the instance, explicitly set as required
  project = "umos-ab24d"

  # Critical instruction: Set deletion_protection to false
  deletion_protection = false

  # Optional: User data script for initial VM setup
  # Note: The customScript from the JSON is included here.
  metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # Optional: Tags can be used for network firewall rules
  # tags = ["http-server", "https-server"]

  # Optional: Allow SSH access if required for management (requires firewall rule)
  # service_account {
  #   email  = "default"
  #   scopes = ["cloud-platform"]
  # }
}

output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}