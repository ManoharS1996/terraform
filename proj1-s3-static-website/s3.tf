resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "static_website" {
  bucket = "terraform-sample-s3bucket-${random_id.bucket_suffix.hex}"

  force_destroy = true

  tags = {
    Name        = "Terraform Static Website"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "static_website" {
  depends_on = [
    aws_s3_bucket_ownership_controls.static_website,
    aws_s3_bucket_public_access_block.static_website
  ]

  bucket = aws_s3_bucket.static_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.static_website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_policy" "static_website_public_read" {
  depends_on = [
    aws_s3_bucket_public_access_block.static_website
  ]

  bucket = aws_s3_bucket.static_website.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"

        Action = [
          "s3:GetObject"
        ]

        Resource = [
          "${aws_s3_bucket.static_website.arn}/*"
        ]
      }
    ]
  })
}

#############################
# Upload index.html
#############################

resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.static_website.id

  key    = "index.html"
  source = "${path.module}/index.html"

  content_type = "text/html"

  etag = filemd5("${path.module}/index.html")

  depends_on = [
    aws_s3_bucket_policy.static_website_public_read
  ]
}

#############################
# Upload error.html
#############################

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.static_website.id

  key    = "error.html"
  source = "${path.module}/error.html"

  content_type = "text/html"

  etag = filemd5("${path.module}/error.html")

  depends_on = [
    aws_s3_bucket_policy.static_website_public_read
  ]
}

#############################
# Outputs
#############################

output "bucket_name" {
  value = aws_s3_bucket.static_website.bucket
}

output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}"
}

output "index_page" {
  value = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}/index.html"
}

output "error_page" {
  value = "http://${aws_s3_bucket_website_configuration.static_website.website_endpoint}/error.html"
}