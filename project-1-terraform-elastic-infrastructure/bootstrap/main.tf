provider "aws" {
  region = "us-east-2"
}

# 1. The S3 Bucket for State Storage
resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-state-storage-project" # Ensure this name is globally unique

  lifecycle {
    prevent_destroy = true # Safety first!
  }
}

# Enable versioning so we can recover from accidental deletions
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 2. The DynamoDB Table for State Locking
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
