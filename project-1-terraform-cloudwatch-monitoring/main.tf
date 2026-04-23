# main.tf

# =============================================
# Provider
# =============================================
provider "aws" {
  region = "us-east-1"
}

# =============================================
# 1. VPC (Required in newer AWS accounts)
# =============================================
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "terraform-cloudwatch-vpc"
  }
}

# =============================================
# 2. Subnet
# =============================================
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# =============================================
# 3. Internet Gateway
# =============================================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

# =============================================
# 4. Route Table
# =============================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# =============================================
# 5. Security Group
# =============================================
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.main.id        # ← This was missing

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
}

# =============================================
# 6. EC2 Instance
# =============================================
resource "aws_instance" "monitored_instance" {
  ami                    = "ami-0c02fb55956c7d316"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "terraform-cloudwatch-project"
  }
}

# =============================================
# 7. SNS Topic + Subscription + CloudWatch Alarm
# =============================================
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"   # ← CHANGE TO YOUR EMAIL
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
  alarm_description   = "CPU utilization is above 70% for 5 minutes"
  alarm_actions       = [aws_sns_topic.cpu_alarm_topic.arn]

  dimensions = {
    InstanceId = aws_instance.monitored_instance.id
  }
}