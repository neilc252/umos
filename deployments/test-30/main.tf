# Configure the Google Cloud provider
# Replace 'umos-ab24d' with your actual GCP Project ID if it differs,
# although it's pre-filled based on the configuration.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource: Google Compute Instance
# This block defines the virtual machine to be deployed on Google Cloud Platform.
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance.
  name         = "test-30"
  # The machine type defines the CPU and memory of the instance.
  machine_type = "e2-micro"
  # The zone where the instance will be created. We'll use a common zone within the specified region.
  zone         = "us-central1-a"
  # The GCP project ID where the instance will be deployed.
  project      = "umos-ab24d"

  # Boot disk configuration for the virtual machine.
  boot_disk {
    initialize_params {
      # The source image for the boot disk. This uses the specified custom image name.
      image = "ubuntu-22-04-19153100893"
    }
  }

  # Network interface configuration.
  # This configures the primary network interface for the VM.
  network_interface {
    # Specifies the VPC network to which the instance will be connected.
    # 'default' refers to the default VPC network in your project.
    network = "default"
    # To assign a public IP address, uncomment the following block:
    # access_config {
    #   # Ephemeral public IP address.
    # }
  }

  # Specifies whether deletion protection is enabled for the instance.
  # When true, the instance cannot be deleted via API calls.
  deletion_protection = false

  # Allows Terraform to stop and update the instance when certain configuration changes occur.
  # This is a good practice for many instance types to avoid re-creation during updates.
  allow_stopping_for_update = true

  # No user_data script is included as per critical instructions.
}

# Output: Private IP Address
# This output block exposes the private IP address of the deployed virtual machine.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}