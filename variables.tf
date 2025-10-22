# Simple Variables for YouTube-like Service

variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "youtube-clone"
}

variable "alert_email" {
  description = "Email address for cost alerts"
  type        = string
  default     = ""
}
