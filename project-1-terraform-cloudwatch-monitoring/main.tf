# =============================================
# Provider
# =============================================
provider "aws" {
  region = "us-east-2"
}

# =============================================
# Data
# =============================================
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# =============================================
# Local Values
# =============================================
locals {
  common_tags = {
    Project     = "cloud-ops-portfolio"
    Environment = "dev"
    Owner       = "joseph"
    ManagedBy   = "terraform"
    Purpose     = "complete-project"
  }
}

# =============================================
# Networking Module
# =============================================
module "network" {
  source      = "./modules/network"
  common_tags = local.common_tags
}

# =============================================
# Compute Module
# =============================================
module "compute" {
  source = "./modules/compute"

  # Wiring: Passing data from root/modules into the compute module
  vpc_id        = module.network.vpc_id
  subnet_id     = module.network.subnet_id
  ami_id        = data.aws_ami.amazon_linux_2023.id # <--- Connecting the root data source to the module
  allowed_ip    = var.allowed_ip
  alert_email   = var.alert_email
  common_tags   = local.common_tags
  instance_type = "t3.micro"
}

# =============================================
# Outputs
# =============================================
output "ec2_public_ip" {
  value       = module.compute.ec2_public_ip
  description = "Public IP from the compute module"
}

output "sns_topic_arn" {
  value       = module.compute.sns_topic_arn
  description = "SNS Topic ARN from the compute module"
}
