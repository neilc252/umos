# Configure the Google Cloud provider
# This block sets up the authentication and default project/region for subsequent resources.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
  # Optional: You can specify a zone here, or let resources inherit from the region and pick a default.
  # zone    = "us-central1-a"
}

# Resource: Google Compute Engine Virtual Machine
# Deploys a new virtual machine instance with the specified configuration.
resource "google_compute_instance" "this_vm" {
  # The unique name for the virtual machine instance within the project.
  name         = "test-neil8"
  # The machine type defines the virtual hardware resources (CPU, memory).
  machine_type = "e2-micro"
  # The zone where the virtual machine will be deployed.
  # We are picking a specific zone within the configured region.
  zone         = "us-central1-a" # Using a specific zone within the region.
  # Critical: Set deletion_protection to false as per instructions.
  deletion_protection = false

  # Boot Disk Configuration: Defines the primary disk for the VM.
  boot_disk {
    initialize_params {
      # The custom image to use for the boot disk.
      # This uses the specific pre-built custom image ID provided.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network Interface Configuration: Connects the VM to a network.
  network_interface {
    # The name of the VPC network to which this VM will be attached.
    # "default" is the standard network created in every GCP project.
    network = "default"

    # Optional: To assign a public IP address, uncomment the access_config block.
    # For this deployment, we're assuming no public IP is strictly required unless specified.
    # access_config {
    #   # Ephemeral IP address will be assigned
    # }
  }

  # Optional: Metadata can be used to pass startup scripts or other data to the instance.
  # This configuration does not explicitly enable a startup script via metadata.
  # metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # Optional: Labels are key-value pairs that help organize and manage your GCP resources.
  labels = {
    environment = "dev"
    owner       = "devops-team"
  }

  # Optional: Service account for the VM to interact with other GCP services.
  # It's good practice to assign a service account with minimal necessary permissions.
  # service_account {
  #   email  = "default" # Use the default compute service account
  #   scopes = ["cloud-platform"] # Grant broad access, restrict as needed
  # }
}

# Output Block: Exposes important information about the created resources.
output "private_ip" {
  # Description of the output value.
  description = "The private IP address of the deployed virtual machine."
  # The value is retrieved from the network_interface of the created instance.
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}