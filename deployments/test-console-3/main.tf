# Configure the Google Cloud provider
# Replace 'umos-ab24d' with your actual GCP project ID if it differs.
# Replace 'us-central1' with your desired GCP region.
provider "google" {
  project = "umos-ab24d"
  region  = "us-central1"
}

# Generate a new SSH key pair for the virtual machine
# This resource creates a private key locally and derives the public key from it.
resource "tls_private_key" "admin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Deploy the Google Compute Engine virtual machine
resource "google_compute_instance" "this_vm" {
  # VM instance name
  name = "test-console-3"
  # Machine type (e.g., e2-micro, n1-standard-1)
  machine_type = "e2-micro"
  # Zone where the VM will be deployed. Pick a zone within the specified region.
  zone = "us-central1-a"
  # Project ID where the VM will be deployed
  project = "umos-ab24d"

  # Boot disk configuration
  boot_disk {
    initialize_params {
      # Use the specified custom image name for the boot disk
      # This image is expected to be available within your GCP project or a shared project.
      image = "ubuntu-22-04-19155927176"
    }
  }

  # Network interface configuration
  # This configuration attaches the VM to the 'default' network and assigns a dynamic public IP.
  network_interface {
    network = "default"
    # Access config to assign an external IP address. Remove this block if only private IP is needed.
    access_config {
      # Ephemeral IP
    }
  }

  # Metadata to inject SSH public keys for user 'packer'
  # This allows SSH access using the generated private key.
  metadata = {
    ssh-keys = "packer:${tls_private_key.admin_ssh.public_key_openssh}"
  }

  # Set deletion protection for the instance
  # 'false' means the instance can be deleted without specific action
  deletion_protection = false

  # Optional: Configure service account for the VM if it needs to interact with other GCP services
  # service_account {
  #   email  = "default" # Use the default compute service account
  #   scopes = ["cloud-platform"] # Grant broad access, restrict as needed
  # }
}

# Output the private IP address of the created virtual machine
output "private_ip" {
  description = "The private IP address of the Google Compute Engine instance."
  value       = google_compute_instance.this_vm.network_interface[0].network_ip
}

# Output the generated private SSH key
# This output is marked as sensitive and will not be displayed in plaintext in the console.
output "private_ssh_key" {
  description = "The private SSH key used to access the virtual machine. Keep this secure!"
  value       = tls_private_key.admin_ssh.private_key_pem
  sensitive   = true
}