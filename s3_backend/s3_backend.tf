terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.44.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  profile = "vpetgangtest"
}

resource "aws_s3_bucket" "s3_bucket_terraform_state" {
  bucket_prefix = "circle-ci-backend-001-"
  # Enable versioning so we can see the full revision history of our
  # state files
  force_destroy = true
  versioning {
    enabled = true
  }
  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket_terraform_state.bucket
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}