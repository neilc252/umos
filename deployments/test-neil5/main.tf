# Terraform block to specify required providers and their versions
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Specify a compatible version for the Google provider
    }
  }
}

# Configure the Google Cloud provider
# The 'project' and 'region' are specified here for global provider settings.
provider "google" {
  project = "umos-ab24d" # GCP project ID derived from the configuration
  region  = "us-central1"  # GCP region derived from the configuration
}

# Resource block for the Google Compute Instance
# CRITICAL INSTRUCTION: The primary compute resource MUST be named "this_vm"
resource "google_compute_instance" "this_vm" {
  name         = "test-neil5"     # Instance name derived from the configuration
  machine_type = "e2-micro"        # VM size/machine type derived from the configuration
  zone         = "us-central1-c"   # A specific zone within the specified region for instance deployment
  project      = "umos-ab24d"      # GCP project ID explicitly used as per critical instruction

  # CRITICAL INSTRUCTION: Use 'deletion_protection' and set to false
  deletion_protection = false # Disables deletion protection for the VM

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # IMPORTANT: Use the pre-built custom image name directly as specified in the instructions
      # This overrides any generic image IDs in the platform.osImageId field of the JSON.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  # The VM is attached to the 'default' VPC network.
  network_interface {
    network = "default" # Connects the VM to the default VPC network
    # An access_config block can be added here if a public IP address is desired,
    # but it's not explicitly requested for this deployment.
    # access_config {
    #   # Assigns an ephemeral public IP address
    # }
  }

  # IMPORTANT: The 'customScript' from the JSON configuration is noted as
  # "User data scripts are not yet supported for direct deployment" and thus
  # is not included as a startup-script in the metadata.
}

# Output block to expose the private IP address of the created virtual machine
# CRITICAL INSTRUCTION: The output block MUST be named "private_ip"
output "private_ip" {
  description = "The private IP address of the created Google Compute Instance."
  # CRITICAL INSTRUCTION: Specific output value for GCP instances
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}