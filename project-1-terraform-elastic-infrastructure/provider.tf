provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket         = "tf-state-storage-project"
    key            = "project-1/terraform.tfstate" # This creates a 'folder' in S3
    region         = "us-east-2"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
