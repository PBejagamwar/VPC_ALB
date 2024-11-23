Terraform AWS setup for web server with VPC and ALB.

Setup and Run Instructions:

Pre-requisites

Install Terraform.
Configure AWS CLI with necessary credentials (aws configure).
Ensure your IAM role/user has permissions to create and manage VPCs, subnets, ALBs, EC2 instances, and other required resources.

Clone the Repository

git clone

cd VPC_ALB

Review Variables

Put your ip address in the ec2.tf file in aws_security_group_rule

Initialize Terraform

terraform init


Validate the Infrastructure

terraform validate

Plan the Infrastructure

terraform plan

Apply the Configuration

terraform apply


Assumptions:

Public Subnet for EC2 Instance

The EC2 instances are placed in the same public subnet as the ALB to get the public IP address of the Ec2 instance.