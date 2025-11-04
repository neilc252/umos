provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

resource "google_compute_instance" "this_vm" {
  # Naming the primary compute resource as "this_vm" as required.
  name         = "test-neil5"
  machine_type = "e2-micro"
  zone         = "us-central1-a" # A specific zone within the specified region

  # Pre-built custom image as specified in the configuration.
  # The 'image' parameter directly uses the provided image name.
  boot_disk {
    initialize_params {
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  network_interface {
    # Using the default network available in most GCP projects.
    network = "default"
    # An access_config block is needed to assign an external IP address,
    # allowing internet connectivity. Though not strictly required for private_ip output,
    # it's common practice for instances that need to reach the internet.
    access_config {
      # Ephemeral IP - Google will assign a public IP address.
    }
  }

  # Ensure deletion_protection is set to false as required.
  deletion_protection = false

  # Allowing the instance to be stopped for updates without replacement.
  allow_stopping_for_update = true

  # Custom script (user data) is explicitly mentioned as not directly supported
  # for deployment via this mechanism based on the input configuration.
  # If needed, this would typically go into metadata_startup_script.
  # metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # Labels can be added for organization and billing.
  labels = {
    env  = "dev"
    owner = "infrastructure-team"
  }

  # Enable guest OS features like shield VM, if desired
  # guest_accelerator {
  #   type  = "nvidia-tesla-v100"
  #   count = 1
  # }
}

# Output block to expose the private IP address of the created VM.
output "private_ip" {
  description = "The private IP address of the virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}