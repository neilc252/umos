# Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Region for deploying the virtual machine
}

# Data source to find the custom AMI ID
# This searches for the pre-built custom image in the account.
data "aws_ami" "this_ami" {
  most_recent = true # Select the most recent matching AMI
  owners      = ["self"] # Look for AMIs owned by the current account

  filter {
    name   = "name"
    values = ["ubuntu-20-04-19118417483"] # Actual cloud image name provided
  }
}

# Deploy the AWS EC2 instance (virtual machine)
resource "aws_instance" "this_vm" {
  # Use the ID of the custom AMI found by the data source
  ami           = data.aws_ami.this_ami.id
  instance_type = "t2.micro" # Instance size for the VM

  # Tag the instance for identification
  tags = {
    Name = "test-c-1" # Name of the instance
  }

  # IMPORTANT: user_data (for software installation) is not included as per instructions.
  # Software installation is handled by a separate process after deployment.
}

# Output the private IP address of the deployed virtual machine
output "private_ip" {
  description = "The private IP address of the created virtual machine."
  value       = aws_instance.this_vm.private_ip
}