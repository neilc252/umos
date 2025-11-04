# Configure the Google Cloud provider
# Ensure you have authenticated Terraform with GCP (e.g., using `gcloud auth application-default login`)
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Resource: Google Compute Engine Virtual Machine
# Deploys a virtual machine instance named "this_vm"
resource "google_compute_instance" "this_vm" {
  # The name of the virtual machine instance
  name = "test-neil2"

  # The machine type (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"

  # The zone where the VM instance will be created.
  # A specific zone within the specified region (us-central1) is required for instance creation.
  zone = "us-central1-a"

  # Project ID for the instance, explicitly set to ensure it's correct.
  project = "umos-ab24d"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # Custom image name for the boot disk.
      # This image is expected to be available in the specified project.
      image = "ubuntu-20-04-gcp-19045279782"
    }
  }

  # Network interface configuration
  network_interface {
    # Connects the VM to the 'default' VPC network.
    # If a specific network is required, it should be defined elsewhere.
    network = "default"

    # No access_config block means the VM will only have a private IP and no external IP.
    # If public access is needed, an access_config {} block should be added.
  }

  # Set deletion_protection to false as per requirements.
  deletion_protection = false

  # Define an array of service accounts to associate with the instance.
  # This grants the VM permissions to interact with GCP services.
  # If specific permissions are needed, create a dedicated service account and roles.
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  # Optional: Apply metadata to the instance
  # The custom script from the configuration is noted as not directly supported
  # for this deployment type and custom image scenario.
  # If a startup script is required, it can be added here using `metadata_startup_script`.
  # For example:
  # metadata_startup_script = "#!/bin/bash\necho 'Hello from startup script!'"

  # Labels are optional key-value pairs that help organize and manage resources.
  labels = {
    environment = "dev"
    created_by  = "terraform"
  }

  # Comments for the instance, visible in the GCP Console.
  description = "Virtual machine deployed via Terraform using a custom Ubuntu image."
}

# Output block: private_ip
# Exports the private IP address of the created virtual machine.
output "private_ip" {
  description = "The private IP address of the virtual machine."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}