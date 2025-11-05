# Configure the AWS provider with the specified region.
provider "aws" {
  region = "us-east-1"
}

# Data source to find the custom Ubuntu AMI by its exact name.
# This ensures the instance uses the specific pre-built image as instructed.
data "aws_ami" "this_ami" {
  # Retrieve the most recent AMI if multiple match the criteria.
  most_recent = true
  # Filter AMIs to only those owned by the current AWS account.
  owners      = ["self"]

  # Filter by the specified image name for the custom AMI.
  filter {
    name   = "name"
    values = ["ubuntu-20.04-aws-19118417483"]
  }
}

# Resource to deploy the AWS EC2 virtual machine.
# The primary compute resource is named 'this_vm' as required.
resource "aws_instance" "this_vm" {
  # Use the ID of the custom AMI found by the 'this_ami' data source.
  ami           = data.aws_ami.this_ami.id
  # Specify the instance type (VM size) as provided in the configuration.
  instance_type = "t2.micro"

  # Assign a name tag to the instance for easy identification in the AWS console.
  tags = {
    Name = "test-neil-3"
  }

  # CRITICAL INSTRUCTION: Do NOT include 'user_data' or 'custom_data'
  # as software installation is handled by a separate process.
}

# Output block named 'private_ip' to expose the private IP address of the VM.
# This adheres to the critical instruction for exposing the private IP.
output "private_ip" {
  description = "The private IP address of the deployed virtual machine."
  value       = aws_instance.this_vm.private_ip
}