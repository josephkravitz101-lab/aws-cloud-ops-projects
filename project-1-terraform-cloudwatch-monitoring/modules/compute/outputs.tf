output "instance_id" {
  value = aws_instance.monitored_instance.id
}

output "ec2_public_ip" {
  value       = aws_instance.monitored_instance.public_ip
  description = "Public IP of the EC2 instance"
}

output "sns_topic_arn" {
  value       = aws_sns_topic.cpu_alarm_topic.arn
  description = "ARN of the SNS topic"
}