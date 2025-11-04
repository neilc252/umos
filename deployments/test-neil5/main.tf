# Configure the Google Cloud provider
# The project and region are derived from the configuration.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource for the Google Compute Engine virtual machine
# The resource is named 'this_vm' as per critical instructions.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance
  name = "test-neil5"

  # The machine type defines the VM's CPU and memory
  machine_type = "e2-micro"

  # The zone where the VM will be deployed.
  # A default zone in the specified region is chosen.
  zone = "us-central1-a"

  # The Google Cloud Project ID where the VM will be created.
  # This comes directly from the 'gcp_project_id' in the configuration.
  project = "umos-ab24d"

  # Boot disk configuration for the virtual machine
  boot_disk {
    initialize_params {
      # The custom image to use for the boot disk.
      # This name is taken directly from the critical instructions.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration for the VM
  network_interface {
    # Connects the VM to the 'default' VPC network.
    # Adjust this if a specific network is required.
    network = "default"

    # An access_config block assigns an ephemeral public IP address to the VM.
    # Remove this block if only a private IP is desired.
    access_config {
      # An empty block means an ephemeral external IP address will be assigned.
    }
  }

  # Set deletion protection to false as required by the instructions.
  # This allows the VM to be deleted via Terraform without manual intervention.
  deletion_protection = false

  # Optional: Metadata can be used for startup scripts or other instance properties.
  # For example, to run a startup script:
  # metadata = {
  #   startup-script = "#!/bin/bash\n echo 'Hello from startup script!' > /tmp/startup.txt"
  # }
}

# Output block to expose the private IP address of the created virtual machine.
# This follows the naming convention 'private_ip' as per critical instructions.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  # The value correctly references the network_ip from the first network interface.
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}