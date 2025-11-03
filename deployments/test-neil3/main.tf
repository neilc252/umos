# Configure the Google Cloud Platform (GCP) provider
# Ensure you have authenticated your Terraform environment with GCP.
# This typically involves `gcloud auth application-default login`
# or setting GOOGLE_APPLICATION_CREDENTIALS environment variable.
provider "google" {
  project = "umos-ab24d" # GCP project ID specified in the configuration
  region  = "us-central1" # Default region for resources that are regional
}

# Resource: google_compute_instance - Virtual Machine deployment
# This block defines the configuration for a single virtual machine instance on GCP.
resource "google_compute_instance" "vm_instance" {
  # The name of the virtual machine instance, as specified in the configuration.
  name         = "test-neil3"
  # The machine type (e.g., CPU and memory configuration) for the VM.
  # "e2-micro" is a cost-effective machine type suitable for small workloads.
  machine_type = "e2-micro"
  # The specific zone where the VM instance will be deployed.
  # We append '-a' to the region to select a default zone if not explicitly provided.
  zone         = "us-central1-a"
  # Set deletion protection to false as explicitly required.
  # When true, the instance cannot be deleted via the Google Cloud Console or API.
  deletion_protection = false

  # Define the boot disk configuration for the VM.
  boot_disk {
    initialize_params {
      # The custom image to use for the boot disk.
      # This is a pre-built custom image name specified in the configuration.
      # IMPORTANT: This uses the image name 'ubuntu-20-04-gcp-19045279782' directly.
      image = "ubuntu-20-04-gcp-19045279782"
      # You can also specify the disk type (e.g., "pd-standard", "pd-ssd")
      # and disk size in GB if needed.
      # type = "pd-standard"
      # size = 20 # GB
    }
  }

  # Define the network interface for the VM.
  network_interface {
    # The name of the VPC network to which the VM will connect.
    # "default" refers to the default network in the GCP project.
    network = "default"

    # Access config to assign a public IP address.
    # Set this to an empty block to automatically assign an ephemeral external IP.
    # If you do not want an external IP, remove this block or set `network_ip` for internal IP only.
    access_config {
      # An empty block means an ephemeral external IP address will be assigned.
      # You can specify a `nat_ip` here for a reserved static external IP address.
    }
  }

  # Optional: Provide metadata for the instance, including a startup script.
  # The 'customScript' from the configuration is included here.
  # This script will run once when the instance starts for the first time.
  # Note the comment in the custom script itself regarding direct deployment support.
  metadata_startup_script = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"

  # Optional: Allow specific service accounts to be attached for identity and access management.
  # This typically grants the VM instance specific permissions within GCP.
  # service_account {
  #   # email  = "default" # Use the default compute service account
  #   # scopes = ["cloud-platform"] # Grant full access to all Cloud APIs
  # }

  # Optional: Configure tags for networking rules, firewalls, etc.
  # tags = ["web-server", "http-traffic"]

  # Optional: Scheduling options, e.g., for preemptible instances.
  # scheduling {
  #   preemptible = false
  #   on_host_maintenance = "MIGRATE"
  # }
}