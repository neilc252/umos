# Configure the AWS provider
# Specify the region where resources will be deployed
provider "aws" {
  region = "us-east-1" # Value from platform.region
}

# Resource: AWS EC2 Instance
# Deploys a virtual machine on Amazon Web Services.
# The resource name is explicitly set to "this_vm" as per requirements.
resource "aws_instance" "this_vm" {
  # Specify the Amazon Machine Image (AMI) to use for the instance.
  # This uses a pre-built custom image ID directly, as per instructions.
  ami = "ubuntu-20.04-aws-19118417483" # Value from os.name

  # Define the instance type, which determines the CPU, memory, and storage capacity.
  instance_type = "t2.micro" # Value from platform.vmSize

  # Optional: Key pair name for SSH access.
  # key_name = "your-ssh-key-name"

  # Optional: Security group(s) to allow/deny network traffic.
  # vpc_security_group_ids = ["sg-0123456789abcdef0"]

  # Define tags for the instance, useful for organization and management.
  tags = {
    Name = "test-neil-1" # Value from platform.instanceName
  }

  # User data for initial instance configuration.
  # The configuration indicates user data scripts are not directly supported yet,
  # so this block is commented out or omitted based on the exact interpretation.
  # For now, we omit it as the provided customScript is just a placeholder.
  # user_data = "#!/bin/bash\n# User data scripts are not yet supported for direct deployment.\n"
}

# Output: Private IP Address
# Exposes the private IP address of the created EC2 instance.
output "private_ip" {
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.this_vm.private_ip
}