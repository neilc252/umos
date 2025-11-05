# Configure the AWS provider
# This block specifies the cloud provider and the region where resources will be deployed.
provider "aws" {
  region = "us-east-1" # The AWS region derived from the configuration.
}

# Data source to look up a custom AMI (Amazon Machine Image) by name.
# This is crucial for deploying a VM from a pre-built image as specified.
data "aws_ami" "this_ami" {
  owners      = ["self"]                             # Search for AMIs owned by the current AWS account.
  most_recent = true                                 # Select the most recent AMI if multiple match the criteria.
  filter {
    name   = "name"
    values = ["ubuntu-20-04-19118417483"]            # The exact name of the custom AMI provided in the configuration.
  }
}

# Resource to deploy an EC2 virtual machine instance.
# This block defines the primary compute resource for our deployment.
resource "aws_instance" "this_vm" {
  # CRITICAL INSTRUCTION: The primary compute resource MUST be named "this_vm".
  ami           = data.aws_ami.this_ami.id # The ID of the AMI found by the 'this_ami' data source.
  instance_type = "t2.micro"               # The instance type (VM size) derived from the configuration.

  # Apply tags to the instance for identification and management.
  tags = {
    Name = "test-neil3" # The instance name derived from the configuration.
  }

  # CRITICAL INSTRUCTION: Do NOT include 'user_data' or 'custom_data' as software installation is handled separately.
}

# Output block to expose the private IP address of the deployed virtual machine.
# This allows other Terraform configurations or external systems to easily retrieve this information.
output "private_ip" {
  # CRITICAL INSTRUCTION: Output block MUST be named "private_ip".
  # CRITICAL INSTRUCTION: Value MUST be aws_instance.this_vm.private_ip for AWS.
  description = "The private IP address of the EC2 instance."
  value       = aws_instance.this_vm.private_ip
}