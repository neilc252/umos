# Configure the Google Cloud provider
# Ensure you have authenticated to GCP (e.g., using `gcloud auth application-default login`)
# and set the project for your gcloud CLI or provide credentials directly.
provider "google" {
  project = "umos-ab24d" # GCP project ID specified in the configuration
  region  = "us-central1" # Default region for the provider
}

# Resource: Google Compute Instance
# Deploys a virtual machine instance on Google Cloud Platform.
resource "google_compute_instance" "vm_instance" {
  # The name of the virtual machine instance.
  name = "test-neil1"

  # The machine type defines the CPU and memory resources for the VM.
  machine_type = "e2-micro"

  # The zone where the VM instance will be deployed.
  # We're inferring a zone within the specified region "us-central1".
  zone = "us-central1-a"

  # The project ID where this resource will be deployed.
  # This is explicitly taken from the configuration.
  project = "umos-ab24d"

  # Configure the boot disk for the VM.
  boot_disk {
    initialize_params {
      # Use the custom image ID provided in the configuration.
      # IMPORTANT: This directly uses the image name "ubuntu-20.04-gcp-1762194682673".
      # For custom images within the same project, just the name is often sufficient.
      # If the image is in a different project, specify it as "projects/<image_project>/global/images/<image_name>".
      image = "ubuntu-20.04-gcp-1762194682673"
    }
  }

  # Configure network interfaces for the VM.
  # This uses the default VPC network.
  network_interface {
    network = "default" # Use the default VPC network.

    # Optional: Attach an access config to assign a public IP address.
    # If not needed, remove this block.
    access_config {
      # Assign a public IP. Leave `nat_ip` empty to auto-assign.
    }
  }

  # Metadata startup script for running commands on first boot.
  # The provided customScript is used here.
  metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # Allow HTTP and HTTPS traffic to the VM (optional, adjust as needed).
  # You might need to create firewall rules separately depending on your security policy.
  # For basic testing, enabling these tags can be useful if corresponding firewall rules exist.
  # tags = ["http-server", "https-server"]

  # Optional: Configure service account for the instance.
  # If omitted, the default Compute Engine service account will be used
  # with default scopes or no scopes.
  # service_account {
  #   email  = "default" # Use the default Compute Engine service account.
  #   scopes = ["cloud-platform"] # Grant full access to all Cloud APIs. Adjust scopes as per least privilege principle.
  # }

  # Optional: Delete the boot disk when the instance is deleted.
  # This is usually the desired behavior.
  delete_protection = false

  # Optional: Specify a short description for the instance.
  description = "Virtual machine deployed via Terraform from automated configuration."
}

# Output the IP address of the deployed VM
output "vm_instance_ip_address" {
  description = "The external IP address of the deployed VM instance."
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

# Output the internal IP address of the deployed VM
output "vm_instance_internal_ip_address" {
  description = "The internal IP address of the deployed VM instance."
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}