variable "alert_email" {
  description = "The email address to receive CloudWatch alarms"
  type        = string
}

variable "allowed_ip" {
  description = "Your public IP address for secure SSH access (CIDR block format e.g., X.X.X.X/32)"
  type        = string
}