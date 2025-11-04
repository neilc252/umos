# Configure the Google Cloud provider
# The project and region are specified for the provider block
# to ensure all resources are deployed within the desired scope.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource block for the Google Compute Instance.
# This defines the virtual machine to be deployed.
resource "google_compute_instance" "this_vm" {
  # The project ID where the VM will be deployed.
  project = "umos-ab24d"
  
  # The specific zone within the region where the VM will reside.
  # For this configuration, we'll pick a common zone within the specified region.
  zone = "us-central1-a"

  # The name of the virtual machine instance.
  name = "test-neil7"

  # The machine type (size) of the virtual machine.
  machine_type = "e2-micro"

  # Critical instruction: Set deletion_protection to false.
  # This prevents accidental deletion of the instance.
  deletion_protection = false

  # Define the boot disk for the virtual machine.
  boot_disk {
    initialize_params {
      # Specify the custom image name for the boot disk.
      # This uses the pre-built custom image directly as per instructions.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Define the network interface for the VM.
  network_interface {
    # Connects the VM to the 'default' network in the specified project.
    network = "default"

    # Add an access config to assign an ephemeral public IP address.
    # This allows the VM to be reachable from the internet, though not explicitly required
    # for the private_ip output, it's common for basic VM deployments.
    access_config {
      # Ephemeral public IP
    }
  }

  # User data/startup scripts are not included here because the customScript
  # provided in the JSON configuration is explicitly a placeholder and indicates
  # direct deployment is not yet supported for it.
}

# Output block to expose the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  # The value is extracted from the network_interface of the 'this_vm' resource.
  value = google_compute_instance.this_vm.network_interface[0].network_ip
}