variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "allowed_ip" { type = string }
variable "alert_email" { type = string }
variable "common_tags" { type = map(string) }

variable "ami_id" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  default = "t3.micro"
  type    = string
}