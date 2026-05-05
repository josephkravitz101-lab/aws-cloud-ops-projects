# Security Group
resource "aws_security_group" "allow_ssh" {
  name   = "allow_ssh"
  vpc_id = var.vpc_id

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

# Launch Template
resource "aws_launch_template" "web_template" {
  name_prefix   = "web-server-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    subnet_id                   = var.subnet_id
    security_groups             = [aws_security_group.allow_ssh.id]
    associate_public_ip_address = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server-fleet"
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = 1
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = [var.subnet_id]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking-policy"
  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    # This keeps your fleet CPU average at 50%
    target_value = 50.0
  }
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
# resource "aws_cloudwatch_metric_alarm" "cpu_high" {
#   alarm_name          = "cpu-utilization-high"
#   comparison_operator = "GreaterThanThreshold"
#   evaluation_periods  = 2
#   metric_name         = "CPUUtilization"
#   namespace           = "AWS/EC2"
#   period              = 300
#   statistic           = "Average"
#   threshold           = 70
#   alarm_actions = [
#     aws_sns_topic.cpu_alarm_topic.arn,   # Email alert
#     aws_autoscaling_policy.scale_out.arn # Triggers the ASG to scale
#   ]

#   dimensions = {
#     AutoScalingGroupName = aws_autoscaling_group.web_asg.name
#   }
# }
