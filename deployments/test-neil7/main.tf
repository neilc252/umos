# Configure the Google Cloud provider
# This block sets up the necessary authentication and project context for deploying resources to GCP.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource: google_compute_instance
# This block defines the virtual machine instance to be deployed on Google Cloud Platform.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance.
  name         = "test-neil7"
  # The machine type defines the number of vCPUs and memory for the instance.
  machine_type = "e2-micro"
  # The zone where the instance will be deployed. It should be within the specified region.
  zone         = "us-central1-a" # Using a specific zone within the region.
  # The project ID where the instance will be created.
  project      = "umos-ab24d"

  # Boot disk configuration for the virtual machine.
  boot_disk {
    initialize_params {
      # Specifies the custom image to use for the boot disk.
      # As per instructions, using the exact custom image name provided.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration.
  network_interface {
    # Using the default network. If a custom network is needed, it would be specified here.
    network = "default"
    # To assign an external IP address, an access_config block would be added.
    # For a private IP only, this block is sufficient.
  }

  # Setting deletion_protection to false as required by the instructions.
  # This prevents accidental deletion of the instance.
  deletion_protection = false

  # Optional: Metadata for the instance, can be used for startup scripts.
  # The custom script from the configuration is noted but not directly applied as per comment.
  metadata = {
    # startup-script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
  }

  # Tags can be used for network firewall rules and other resource management.
  tags = ["http-server", "https-server"]
}

# Output Block: private_ip
# This block exports the private IP address of the deployed virtual machine.
# It makes the private IP easily accessible after the Terraform deployment.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  # For GCP, the private IP is found in the network_interface block's network_ip.
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}