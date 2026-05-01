# Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "allow-ssh-sg" })
}

# EC2 Instance
resource "aws_instance" "monitored_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = merge(var.common_tags, { Name = "monitored-instance" })
}

# SNS Topic
resource "aws_sns_topic" "cpu_alarm_topic" {
  name = "cpu-alarm-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.cpu_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu-utilization-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 70
  alarm_actions       = [aws_sns_topic.cpu_alarm_topic.arn]

  dimensions = {
    InstanceId = aws_instance.monitored_instance.id
  }
}