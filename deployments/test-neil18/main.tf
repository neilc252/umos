# Configure the Google Cloud provider
provider "google" {
  project = "umos-ab24d" # GCP project ID specified in the configuration
  region  = "us-central1" # Default region for resources if not specified per-resource
}

# Resource: Google Compute Instance
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance
  name         = "test-neil18"
  # The type of machine to use (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"
  # The zone where the instance will be created (e.g., us-central1-c)
  zone         = "us-central1-c"
  # The project ID where the instance will be created, explicitly required by instructions
  project      = "umos-ab24d"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # The custom image name to use for the boot disk
      # As per instructions, this uses the pre-built custom image directly.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # Connects the VM to the 'default' network
    network = "default"

    # To assign a public IP address, uncomment the following block:
    # access_config {
    #   # Ephemeral public IP
    # }
  }

  # Set deletion protection as required by instructions
  deletion_protection = false

  # Optional: Configure service account for the VM
  # This section can be customized based on required permissions
  service_account {
    email  = "default" # Use the default service account
    scopes = ["cloud-platform"] # Grant full access to all Cloud APIs available to the default service account
  }

  # Optional: Metadata for startup scripts, SSH keys, etc.
  # The configuration notes that startup scripts are not yet supported for direct deployment
  # metadata = {
  #   startup-script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
  # }
}

# Output: Private IP address of the created VM
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  # Access the private IP from the first network interface of the VM
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}