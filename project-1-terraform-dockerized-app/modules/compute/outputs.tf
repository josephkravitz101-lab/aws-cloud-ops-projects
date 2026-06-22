output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.name
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = aws_sns_topic.cpu_alarm_topic.arn
}
