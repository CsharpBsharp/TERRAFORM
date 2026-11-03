# This file will be used to explore different blocks in Terraform 
# This block cannot use variable 
terraform {
  required_version = ">=1.7.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    # https://registry.terraform.io/providers/hashicorp/random/latest
    # Supports the use of randomness within Terraform configurations. This is a logical provider,
    # which means that it works entirely within Terraform logic, and does not interact with any other services.
    # Random is logcial provider 
    # Random is not truly random as purpose of TF is to provide consistent configuration so it generate a random string, 
    # which is kept the same across runs but each independent incarnation of it can have different string. 
    random = {
      source  = "hashicorp/random"
      version = ">=3.9.1"
    }
  }

  # backend and cloud are mutually exclusive 
  # backend is a destination where we would like to save state 
  backend "s3" {
    # bucket         = "my_backend_bucket_to_save_state" # Name of your S3 bucket which already exist. 
    # This bucket was created in 00-bootstrap-state project
    bucket = "cb-tfstate-966662773876-us-east-2"
    # You cannot create a new bucket it must exist 
    key          = "prod/terraform.tfstate" # Path inside the bucket to store the file
    region       = "us-east-2"              # AWS Region where the bucket resides
    encrypt      = true                     # Enables AES-256 server-side encryption
    use_lockfile = true
    # dynamodb_table is deprecated and use_lockfile should be used instead 
    # dynamodb_table = "terraform-lock-table"            # Optional: Used for state locking to prevent conflicts
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
  # This is deprecated and required_version should be used in terraform block
  # version = "~>6.0"
}

# This will generate 6 characters long string which we will append to s3 bucket. to make bucket unique 
# but once itz generated it will stay static for this configuration. So not a true random
resource "random_id" "bucket_suffix" {
  byte_length = 6
}

# We will now create s3 bucket and make use of that random string 
resource "aws_s3_bucket" "example-bucket" {
  bucket = "example-bucket-${random_id.bucket_suffix.hex}"
}

output "bucket_name" {
  value = aws_s3_bucket.example-bucket.bucket
}
