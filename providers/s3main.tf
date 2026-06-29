terraform {
  required_version = "~> 1.7"
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
provider "aws" {
  region = "ap-south-1"
  alias  = "ap-south"
}
resource "aws_s3_bucket" "ap_south_2" {
  bucket = "some-random-bucket-name-aosdhfoadhfu"
}
resource "aws_s3_bucket" "ap_south_1" {
  bucket   = "some-random-bucket-name-18736481364"
  provider = aws.us-east
}