# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource for the Google Compute Engine virtual machine named "this_vm"
resource "google_compute_instance" "this_vm" {
  name         = "test-neil9"
  project      = "umos-ab24d" # Use the provided gcp_project_id for the project
  machine_type = "e2-micro"
  zone         = "us-central1-c" # A specific zone within the specified region

  # Boot disk configuration, using the specified custom image
  boot_disk {
    initialize_params {
      # Use the custom image named 'ubuntu-20-04-gcp-19045279782' as required
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # Assumes a 'default' network exists in the specified GCP project
    network = "default"
  }

  # Set deletion_protection to false as per critical instructions
  deletion_protection = false

  # Metadata for startup script, including the customScript if provided
  metadata = {
    startup-script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
  }
}

# Output block for the private IP address of the VM
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  # For GCP, the private IP is found in the first network interface's network_ip attribute
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}