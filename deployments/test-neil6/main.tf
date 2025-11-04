provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance
  name         = "test-neil6"
  # The machine type for the VM (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"
  # The zone where the VM will be deployed. It should be within the specified region.
  zone         = "us-central1-b" # Using a default zone within us-central1

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # The custom image for the boot disk.
      # This is a pre-built custom image as specified in the instructions.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # The network to attach the VM to. 'default' is the common choice if not specified.
    network = "default"
    # To assign an external IP address, add an access_config block.
    # access_config {
    #   # Ephemeral IP
    # }
  }

  # Set deletion protection to false as per instructions.
  deletion_protection = false

  # Optional: Metadata for startup scripts or other configurations.
  # metadata = {
  #   startup-script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment."
  # }

  # The project ID where the instance will be created.
  project = "umos-ab24d"

  # A list of service accounts to use for the instance.
  # service_account {
  #   email  = "default"
  #   scopes = ["cloud-platform"]
  # }
}

# Output block to expose the private IP address of the virtual machine.
output "private_ip" {
  description = "The private IP address of the created VM."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}