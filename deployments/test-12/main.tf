# Configure the Google Cloud provider
# Ensure your GCP credentials are configured for Terraform to use.
# This typically involves setting GOOGLE_APPLICATION_CREDENTIALS environment variable
# or configuring the gcloud CLI.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource: Google Compute Engine Virtual Machine
# This block defines the 'this_vm' instance based on the provided configuration.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance.
  name         = "test-12"
  # The machine type defines the virtual machine's CPU and memory.
  machine_type = "e2-micro"
  # The zone where the virtual machine will be deployed.
  # Using 'us-central1-a' as a default zone within the specified region 'us-central1'.
  zone         = "us-central1-a"
  # The project ID where the instance will be created.
  project      = "umos-ab24d"

  # Boot disk configuration for the VM.
  boot_disk {
    initialize_params {
      # Specifies the custom image to use for the boot disk.
      # The image is expected to be a custom image within the specified GCP project.
      image = "projects/umos-ab24d/global/images/ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration.
  # The instance will be connected to the default VPC network.
  network_interface {
    network = "default"
  }

  # Set deletion protection to false as per instructions.
  deletion_protection = false

  # Optional: Metadata for startup script (if applicable, not specified for direct deployment here)
  # metadata = {
  #   startup-script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
  # }
}

# Output block to expose the private IP address of the created VM.
# This makes it easy to retrieve the IP address after Terraform applies the configuration.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}