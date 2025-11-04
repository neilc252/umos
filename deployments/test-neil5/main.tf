# Configure the Google Cloud provider
# This block sets up the necessary authentication and target project/region for deployments.
provider "google" {
  project = "umos-ab24d"      # Specifies the Google Cloud project ID from the configuration.
  region  = "us-central1"    # Specifies the default region for resources, from the configuration.
}

# Resource block to define a Google Compute Engine virtual machine instance.
# The resource name "this_vm" is mandated by the critical instructions.
resource "google_compute_instance" "this_vm" {
  name         = "test-neil5"    # The desired name for the virtual machine instance.
  machine_type = "e2-micro"      # The machine type (VM size) for the instance.
  zone         = "us-central1-a" # The specific zone within the region where the VM will be deployed.
                                 # A zone is required for GCP instances; using '-a' as a common default.
  project      = "umos-ab24d"    # Explicitly setting the project ID for the instance resource.

  # Boot disk configuration for the virtual machine.
  boot_disk {
    initialize_params {
      # Specifies the custom image ID to use for the boot disk.
      # This image is pre-built as per critical instructions.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration for the virtual machine.
  network_interface {
    # Connects the VM to the 'default' VPC network.
    # For custom networks, specify the network name here.
    network = "default"

    # To assign a public IP address, an access_config block can be uncommented:
    # access_config {} # This assigns an ephemeral public IP.
  }

  # Critical instruction: Enable or disable deletion protection for the VM.
  # Setting to false as per requirement.
  deletion_protection = false

  # Note: The 'customScript' from the configuration is not directly mapped to
  # a standard 'user-data' or 'startup-script' for GCP instances in this context.
  # If a startup script were needed, it would typically be passed via the 'metadata' block:
  # metadata = {
  #   startup-script = "#!/bin/bash\necho \"Hello from startup script!\" > /tmp/startup.txt"
  # }
}

# Output block to expose the private IP address of the created virtual machine.
# The output name "private_ip" is mandated by the critical instructions.
output "private_ip" {
  description = "The private IP address of the created Google Compute Engine virtual machine."
  # Accesses the private IP from the first network interface of the 'this_vm' instance.
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}