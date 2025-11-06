# Configure the AWS provider
provider "aws" {
  region = "us-east-1"
}

# Data source to find the custom AMI ID based on the provided name
# This assumes the custom image 'ubuntu-22-04-19152071384' exists in your AWS account.
data "aws_ami" "this_ami" {
  most_recent = true
  owners      = ["self"] # Look for AMIs owned by the current account

  filter {
    name   = "name"
    values = ["ubuntu-22-04-19152071384"]
  }
}

# Resource to deploy the AWS EC2 instance
resource "aws_instance" "this_vm" {
  # Use the AMI ID found by the data source
  ami           = data.aws_ami.this_ami.id
  instance_type = "t2.micro" # Specified VM size

  # Tags for identification in AWS console
  tags = {
    Name = "test-neil-29" # Specified instance name
  }

  # CRITICAL: No user_data script is included as per instructions.
  # Software installation is handled by a separate process after deployment.
}

# Output block to expose the private IP address of the deployed VM
output "private_ip" {
  description = "The private IP address of the deployed EC2 instance."
  value       = aws_instance.this_vm.private_ip
}