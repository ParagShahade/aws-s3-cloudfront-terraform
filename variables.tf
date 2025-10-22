# Variables for YouTube-like Service with HA

variable "aws_region" {
  description = "Primary AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "secondary_region" {
  description = "Secondary AWS region for HA"
  type        = string
  default     = "us-west-2"
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

variable "enable_ha" {
  description = "Enable high availability features"
  type        = bool
  default     = true
}

variable "cloudfront_price_class" {
  description = "CloudFront price class for global distribution"
  type        = string
  default     = "PriceClass_All"
  validation {
    condition = contains([
      "PriceClass_All",
      "PriceClass_200", 
      "PriceClass_100"
    ], var.cloudfront_price_class)
    error_message = "CloudFront price class must be one of: PriceClass_All, PriceClass_200, PriceClass_100."
  }
}

# Optional third region in Europe
variable "europe_region" {
  description = "Optional European AWS region for HA/DR"
  type        = string
  default     = "eu-west-1"
}

variable "enable_europe" {
  description = "Enable European region resources"
  type        = bool
  default     = false
}
