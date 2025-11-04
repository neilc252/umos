# Configure the Google Cloud provider
# This block sets up the credentials and default project/region for resources.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource: Google Compute Engine Virtual Machine Instance
# This block defines the configuration for a single virtual machine instance on GCP.
resource "google_compute_instance" "vm_instance" {
  # The name of the virtual machine instance, as specified in the configuration.
  name = "test-neil4"

  # The Google Cloud project ID where the instance will be deployed.
  # This MUST use the 'gcp_project_id' provided in the configuration.
  project = "umos-ab24d"

  # The zone where the instance will be deployed.
  # A specific zone within the given region is required (e.g., us-central1-a).
  zone = "us-central1-a"

  # The machine type defines the number of virtual CPUs and memory available to the instance.
  machine_type = "e2-micro"

  # Boot disk configuration for the virtual machine.
  boot_disk {
    # Parameters for initializing the boot disk.
    initialize_params {
      # The custom image to use for the boot disk.
      # As per the instructions, this uses the pre-built custom image name directly.
      # It is 'ubuntu-20-04-gcp-19045279782' from the 'os.name' field.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration for the virtual machine.
  network_interface {
    # The name of the network to attach to. 'default' is commonly used for basic setups.
    network = "default"

    # Access configurations for this interface.
    # An empty 'access_config' block automatically assigns an ephemeral external IP address.
    access_config {
    }
  }

  # Deletion protection setting for the instance.
  # As per the requirement, 'deletion_protection' is set to 'false'.
  deletion_protection = false

  # Note: The 'customScript' from the input JSON configuration is not included as a startup script.
  # The configuration explicitly states: "User data scripts are not yet supported for direct deployment."
}