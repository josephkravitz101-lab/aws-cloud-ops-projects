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

# 1. The "Identity Provider" - The digital handshake between AWS and GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # Standard thumbprint for GitHub's certificate
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# 2. The "Role" - The set of permissions GitHub will "wear"
resource "aws_iam_role" "github_actions_role" {
  name = "GitHubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Condition = {
        # IMPORTANT: This ensures ONLY your repo can use this role
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:josephkravitz101-lab/aws-cloud-ops-projects:*"
        }
      }
    }]
  })
}

# 3. The "Permissions" - Allowing the role to manage your resources
resource "aws_iam_role_policy_attachment" "gha_admin" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_role.arn
}
