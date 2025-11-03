# Configure the Google Cloud provider.
# Ensure you have authenticated to GCP (e.g., `gcloud auth application-default login`)
# and set your project (`gcloud config set project your-gcp-project-id`).
provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# --- Input Variables ---

# The GCP Project ID where resources will be deployed.
# IMPORTANT: Replace the default with your actual GCP Project ID.
variable "gcp_project_id" {
  description = "The GCP project ID to deploy resources into."
  type        = string
  default     = "your-gcp-project-id" # <<<--- CHANGE THIS TO YOUR ACTUAL GCP PROJECT ID
}

# The GCP region for the virtual machine, as specified in the configuration.
variable "gcp_region" {
  description = "The GCP region for the VM instance."
  type        = string
  default     = "us-central1"
}

# The GCP zone for the virtual machine.
# A specific zone within the region must be chosen, as the configuration only provides a region.
variable "gcp_zone" {
  description = "The GCP zone for the VM instance."
  type        = string
  default     = "us-central1-c" # Default to 'us-central1-c', you can change this to another zone in us-central1.
}

# The desired name for the VM instance, as specified in the configuration.
variable "instance_name" {
  description = "Name of the Google Compute Engine virtual machine instance."
  type        = string
  default     = "test-neil"
}

# The machine type for the VM instance, as specified in the configuration.
variable "machine_type" {
  description = "Machine type for the VM instance (e.g., e2-micro, n1-standard-1)."
  type        = string
  default     = "e2-micro"
}

# The name of the pre-built custom image to use for the boot disk.
# As per instructions, this is used directly in the 'source_image' equivalent parameter.
variable "source_image" {
  description = "The name of the pre-built custom image to use for the VM's boot disk."
  type        = string
  default     = "ubuntu-20.04-gcp-1762194682673"
}

# Startup script to be executed on the VM after creation.
# This script will run as root on the first boot using GCP's metadata startup-script feature.
variable "startup_script" {
  description = "A bash script to run on the VM instance at first boot."
  type        = string
  default     = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
}

# --- Google Compute Engine VM Instance Resource ---

resource "google_compute_instance" "vm_instance" {
  # The name of the virtual machine instance.
  name         = var.instance_name
  # The machine type defines the CPU and memory resources for the VM.
  machine_type = var.machine_type
  # The specific zone within the chosen region for deploying the VM.
  zone         = var.gcp_zone

  # Configuration for the boot disk of the VM.
  boot_disk {
    initialize_params {
      # Specifies the image to use for the boot disk.
      # For GCP, the custom image name is directly provided here via the 'image' parameter,
      # which serves as the 'source_image' equivalent as per instructions.
      image = var.source_image
    }
  }

  # Network interface configuration.
  # This configuration uses the 'default' VPC network, which is present in all GCP projects.
  # An 'access_config' block without further parameters assigns an ephemeral public IP address
  # to the instance, allowing internet access.
  network_interface {
    network = "default"
    access_config {} # Assign an ephemeral public IP address
  }

  # Metadata key-value pairs for the instance.
  # The 'startup-script' key is special in GCP and causes the value to be executed
  # as a script on the VM's first boot.
  metadata = {
    startup-script = var.startup_script
  }

  # Service account configuration.
  # The 'default' service account is used here with broad 'cloud-platform' access scope.
  # In production environments, it's highly recommended to use a custom service account
  # with the minimal necessary permissions (least privilege principle).
  service_account {
    email  = "default"
    scopes = ["cloud-platform"] # Grants broad access for various GCP APIs, adjust as needed.
  }

  # Network tags can be used to apply firewall rules to this instance.
  # These are example tags; adjust them according to your specific firewall configuration.
  tags = ["http-server", "https-server"]
}

# --- Outputs ---

# Output the external (public) IP address of the deployed VM instance.
# This allows you to easily connect to your VM after deployment.
output "instance_external_ip" {
  description = "The external IP address of the VM instance."
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

# Output the internal (private) IP address of the deployed VM instance.
# This is useful for internal network communication within your GCP VPC.
output "instance_internal_ip" {
  description = "The internal IP address of the VM instance."
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}