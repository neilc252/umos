# Configure the Google Cloud provider
provider "google" {
  # The GCP project ID where resources will be deployed
  project = "umos-ab24d"
  # The GCP region for resource deployment
  region  = "us-central1"
}

# Resource block for the Google Compute Engine Virtual Machine
resource "google_compute_instance" "this_vm" {
  # CRITICAL INSTRUCTION: The primary compute resource MUST be named "this_vm"
  name         = "test-neil6" # Instance name from the configuration
  machine_type = "e2-micro"   # Machine type (VM size) from the configuration
  # GCP instances require a zone. Since only a region was provided,
  # we append '-a' to the region to specify a default zone within it.
  zone         = "us-central1-a"
  project      = "umos-ab24d" # CRITICAL INSTRUCTION: Use gcp_project_id for the project field

  # CRITICAL INSTRUCTION: Use 'deletion_protection = false'
  deletion_protection = false

  # Configuration for the boot disk of the virtual machine
  boot_disk {
    initialize_params {
      # CRITICAL INSTRUCTION: Use the custom image name directly from the configuration
      # This specifies the pre-built custom image to be used for the VM's boot disk.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Configuration for the network interface
  network_interface {
    # Assumes a 'default' network exists in the specified project and region.
    # If a specific network is required, it should be defined or referenced here.
    network = "default"

    # Optional: Add an access_config block if an external (public) IP address is needed.
    # access_config {
    #   # This block configures an ephemeral public IP address.
    # }
  }

  # The 'customScript' field in the input indicates that user data scripts
  # are not directly supported for this deployment method, so metadata_startup_script
  # is intentionally omitted.

  # Optional: Add labels for better resource management and identification
  labels = {
    environment = "dev"
    owner       = "devops-team"
    created_by  = "terraform"
  }
}

# CRITICAL INSTRUCTION: Output block named "private_ip"
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  # CRITICAL INSTRUCTION: For GCP, the value must be network_interface[0].network_ip
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}