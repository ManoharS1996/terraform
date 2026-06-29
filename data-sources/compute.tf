# ----------------------------------------
# AWS Caller Identity
# ----------------------------------------
data "aws_caller_identity" "current" {}

# ----------------------------------------
# AWS Availability Zones
# ----------------------------------------
data "aws_availability_zones" "available" {
  state = "available"
}

# ----------------------------------------
# Latest Amazon Linux 2023 AMI
# ----------------------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ----------------------------------------
# Create Dev VPC
# ----------------------------------------
resource "aws_vpc" "dev" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "dev"
  }
}

# ----------------------------------------
# Create Prod VPC
# ----------------------------------------
resource "aws_vpc" "prod" {
  cidr_block = "10.2.0.0/16"

  tags = {
    Name = "prod"
  }
}

# ----------------------------------------
# Read Dev VPC
# ----------------------------------------
data "aws_vpc" "dev" {
  depends_on = [aws_vpc.dev]

  filter {
    name   = "tag:Name"
    values = ["dev"]
  }
}

# ----------------------------------------
# Read Prod VPC
# ----------------------------------------
data "aws_vpc" "prod" {
  depends_on = [aws_vpc.prod]

  filter {
    name   = "tag:Name"
    values = ["prod"]
  }
}

# ----------------------------------------
# Read Test VPC
# ----------------------------------------
data "aws_vpc" "test" {
  filter {
    name   = "tag:Name"
    values = ["test"]
  }
}

# ----------------------------------------
# EC2 Instance
# ----------------------------------------
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  availability_zone           = data.aws_availability_zones.available.names[0]
  associate_public_ip_address = true

  tags = {
    Name = "test"
  }

  root_block_device {
    volume_size           = 80
    volume_type           = "gp3"
    delete_on_termination = true
  }
}

# ----------------------------------------
# IAM Policy - S3 Read Only
# ----------------------------------------
resource "aws_iam_policy" "s3_read_only" {
  name        = "S3ReadOnlyPolicy"
  description = "Allows read-only access to Amazon S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*"
        ]
      }
    ]
  })
}

# ----------------------------------------
# IAM Policy - EC2 Read Only
# ----------------------------------------
resource "aws_iam_policy" "ec2_read_only" {
  name        = "EC2ReadOnlyPolicy"
  description = "Allows read-only access to Amazon EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:Describe*"
        ]

        Resource = "*"
      }
    ]
  })
}

# ----------------------------------------
# IAM Policy - CloudWatch Read Only
# ----------------------------------------
resource "aws_iam_policy" "cloudwatch_read_only" {
  name        = "CloudWatchReadOnlyPolicy"
  description = "Allows read-only access to Amazon CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Action = [
          "cloudwatch:Get*",
          "cloudwatch:List*",
          "cloudwatch:Describe*"
        ]

        Resource = "*"
      }
    ]
  })
}

# ----------------------------------------
# AWS Outputs
# ----------------------------------------
output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_arn" {
  value = data.aws_caller_identity.current.arn
}

# ----------------------------------------
# Availability Zone Outputs
# ----------------------------------------
output "availability_zone_names" {
  value = data.aws_availability_zones.available.names
}

output "availability_zone_ids" {
  value = data.aws_availability_zones.available.zone_ids
}

output "first_availability_zone" {
  value = data.aws_availability_zones.available.names[0]
}

# ----------------------------------------
# AMI Outputs
# ----------------------------------------
output "ami_id" {
  value = data.aws_ami.amazon_linux.id
}

# ----------------------------------------
# Dev VPC Outputs
# ----------------------------------------
output "dev_vpc_id" {
  value = data.aws_vpc.dev.id
}

output "dev_vpc_cidr" {
  value = data.aws_vpc.dev.cidr_block
}

# ----------------------------------------
# Prod VPC Outputs
# ----------------------------------------
output "prod_vpc_id" {
  value = data.aws_vpc.prod.id
}

output "prod_vpc_cidr" {
  value = data.aws_vpc.prod.cidr_block
}

# ----------------------------------------
# Test VPC Outputs
# ----------------------------------------
output "test_vpc_id" {
  value = data.aws_vpc.test.id
}

output "test_vpc_cidr" {
  value = data.aws_vpc.test.cidr_block
}

# ----------------------------------------
# EC2 Outputs
# ----------------------------------------
output "instance_id" {
  value = aws_instance.web.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

output "public_dns" {
  value = aws_instance.web.public_dns
}

# ----------------------------------------
# IAM Policy Outputs
# ----------------------------------------
output "s3_policy_arn" {
  value = aws_iam_policy.s3_read_only.arn
}

output "ec2_policy_arn" {
  value = aws_iam_policy.ec2_read_only.arn
}

output "cloudwatch_policy_arn" {
  value = aws_iam_policy.cloudwatch_read_only.arn
}

output "s3_policy_name" {
  value = aws_iam_policy.s3_read_only.name
}

output "ec2_policy_name" {
  value = aws_iam_policy.ec2_read_only.name
}

output "cloudwatch_policy_name" {
  value = aws_iam_policy.cloudwatch_read_only.name
}