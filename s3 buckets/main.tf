terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}
resource "random_id" "bucket_suffix" {
  byte_length = 6
}

resource "aws_s3_bucket" "sample" {
  bucket = var.bucket_name
}
resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-bucket-${random_id.bucket_suffix.hex}"
}

variable "bucket_name" {
  type        = string
  description = "My variable used to set bucket name"
  default     = "manohar-demo-bucket-2026"
}

output "bucket_id" {
  value = aws_s3_bucket.sample.id
}