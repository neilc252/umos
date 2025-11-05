# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Region where the virtual machine will be deployed
}

# Resource to deploy an EC2 instance
resource "aws_instance" "this_vm" {
  # The Amazon Machine Image (AMI) ID for the virtual machine.
  # This is a custom pre-built image as specified in the configuration.
  ami = "ubuntu-20.04-aws-19118417483"

  # The instance type determines the virtual machine's CPU, memory, and storage capacity.
  instance_type = "t2.micro"

  # Tags are key-value pairs that help manage, identify, organize, search for, and filter resources.
  tags = {
    Name = "test-neil-2" # Name tag for the instance, matching the specified instanceName.
  }

  # CRITICAL INSTRUCTION: user_data is intentionally omitted as software installation
  # is handled by a separate process after deployment.
}

# Output block to expose the private IP address of the created virtual machine.
# This provides easy access to the VM's internal IP for further configuration or access.
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = aws_instance.this_vm.private_ip
}