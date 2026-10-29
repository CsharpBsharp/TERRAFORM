terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure aws provider 
provider "aws" {
  region = "us-east-2"
}

# Create a VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform VPC"
  }
}

# Create public subnet
resource "aws_subnet" "terra_pub_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terra_pub_subnet" # <-- This is the actual AWS Name tag
  }
}

# Create private subnet
resource "aws_subnet" "terra_prv_subnet" {
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-2a"

  tags = {
    Name = "terra_prv_subnet" # <-- This is the actual AWS Name tag
  }
}

# Craete internet gateway
resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "Terraform IGW"
  }
}

# Create public route table 
resource "aws_route_table" "terraform_public_rtb" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }

  tags = {
    Name = "Terraform public rtb"
  }
}

# Create private route table 
resource "aws_route_table" "terraform_private_rtb" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "Terraform private rtb"
  }
}

# Associate / Attach public subnet to public route table 
resource "aws_route_table_association" "terraform_public_rtb_association" {
  subnet_id      = aws_subnet.terra_pub_subnet.id
  route_table_id = aws_route_table.terraform_public_rtb.id
}

# Attach private subnet to private route table 
resource "aws_route_table_association" "terraform_private_rtb_association" {
  subnet_id      = aws_subnet.terra_prv_subnet.id
  route_table_id = aws_route_table.terraform_private_rtb.id
}

# Outputs 
output "vpc_id" {
  description = "ID of the Terraform VPC"
  value       = aws_vpc.terraform_vpc.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.terra_pub_subnet.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.terra_prv_subnet.id
}
