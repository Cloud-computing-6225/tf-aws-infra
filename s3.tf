# Generate a unique bucket name with a UUID
resource "random_uuid" "bucket_name" {}

# Create a private S3 bucket with UUID-based name and allow force deletion
resource "aws_s3_bucket" "app_bucket" {
  bucket        = random_uuid.bucket_name.result # Use UUID for unique bucket name
  force_destroy = true                           # Allow deletion even if bucket is not empty

  # Tags for organization
  tags = {
    Name = "${var.project_name}-s3-bucket"
  }
}

# Apply default encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_encryption" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Enable default AES-256 encryption
    }
  }
}

# Define a lifecycle policy to transition objects to STANDARD_IA after 30 days
resource "aws_s3_bucket_lifecycle_configuration" "app_bucket_lifecycle" {
  bucket = aws_s3_bucket.app_bucket.id

  rule {
    id     = "transition_to_ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # Move to Infrequent Access after 30 days
    }
  }
}



