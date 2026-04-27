# =============================================
# 1. Provider Configuration
# =============================================
provider "aws" {
  region = "us-east-2" 
}

# =============================================
# 2. Data Sources
# =============================================
# Dynamically fetches the latest Amazon Linux 2023 AMI for us-east-2
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# =============================================
# 3. Local Values
# =============================================
locals {
  vpc_id      = aws_vpc.main.id
  common_tags = {
    Project     = "cloud-ops-portfolio"
    Environment = "dev"
    Owner       = "joseph"
    ManagedBy   = "terraform"
    Purpose     = "learning-cloudwatch-monitoring"
  }
}

# =============================================
# 4. Networking (VPC & Subnet)
# =============================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(local.common_tags, {
    Name = "main-vpc"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = local.vpc_id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a" # Explicitly avoids AZ-mismatch errors

  tags = merge(local.common_tags, {
    Name = "public-subnet"
  })
}

# =============================================
# 5. Internet Connectivity
# =============================================
resource "aws_internet_gateway" "igw" {
  vpc_id = local.vpc_id

  tags = merge(local.common_tags, {
    Name = "main-igw"
  })
}

resource "aws_route_table" "public" {
  vpc_id = local.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name = "public-route-table"
  })
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# =============================================
# 6. Security Group
# =============================================
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "allow-ssh-sg"
  })
}

# =============================================
# 7. EC2 Instance
# =============================================
resource "aws_instance" "monitored_instance" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = merge(local.common_tags, {
    Name = "monitored-instance"
  })
}

# =============================================
# 8. SNS & Monitoring
# =============================================
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"

  tags = merge(local.common_tags, {
    Name = "cpu-alarm-topic"
  })
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = "testemailgit@gmail.com" # <--- CHANGE THIS!

  depends_on = [aws_sns_topic.cpu_alarm_topic]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "CPU utilization is above 70% for 10 minutes"
  alarm_actions       = [aws_sns_topic.cpu_alarm_topic.arn]

  dimensions = {
    InstanceId = aws_instance.monitored_instance.id
  }

  tags = merge(local.common_tags, {
    Name = "high-cpu-alarm"
  })

  depends_on = [aws_sns_topic.cpu_alarm_topic]
}

# =============================================
# 9. Outputs
# =============================================
output "ec2_public_ip" {
  value       = aws_instance.monitored_instance.public_ip
  description = "Public IP of the EC2 instance"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.cpu_alarm_topic.arn
  description = "ARN of the SNS topic"
}