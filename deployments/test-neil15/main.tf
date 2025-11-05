# Configure the Google Cloud provider
# The 'project' and 'region' are specified based on the provided configuration.
# Authentication is typically handled via `gcloud auth application-default login`
# or by setting GOOGLE_APPLICATION_CREDENTIALS environment variable.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource: google_compute_instance
# Deploys a Google Compute Engine virtual machine instance.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance, derived from platform.instanceName.
  name         = "test-neil15"
  # The machine type (e.g., e2-micro, n1-standard-1), derived from platform.vmSize.
  machine_type = "e2-micro"
  # The zone where the VM will be deployed. We'll pick a zone within the specified region.
  zone         = "us-central1-a"
  # The project ID where the VM will be created, derived from gcp_project_id.
  project      = "umos-ab24d"

  # Boot disk configuration for the VM.
  boot_disk {
    # Configuration for initializing the boot disk.
    initialize_params {
      # The custom image to use for the boot disk, derived from os.name
      # as per critical instructions.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration.
  # This configures the VM to connect to the 'default' network.
  # An access config is added to assign an ephemeral public IP for external connectivity.
  network_interface {
    network = "default"
    # Assign an ephemeral public IP address. Remove this block if no public IP is needed.
    access_config {
      # Empty block for default behavior (ephemeral IP)
    }
  }

  # Prevent accidental deletion of this VM instance.
  # Setting to 'false' as per critical instructions.
  deletion_protection = false

  # Metadata block for startup scripts.
  # The provided custom script indicates it's not directly supported for this deployment method yet.
  # If a valid startup script were provided, it would be placed here, e.g.:
  # metadata_startup_script = "#!/bin/bash\n echo 'Hello, world!' > /tmp/hello.txt"
}

# Output block to expose the private IP address of the created VM.
# The value is obtained from the network_interface block of the google_compute_instance resource.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}