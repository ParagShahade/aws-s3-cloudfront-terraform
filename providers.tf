# Terraform and AWS Provider Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Primary region provider
provider "aws" {
  alias  = "primary"
  region = var.aws_region
  
  default_tags {
    tags = {
      Service     = var.service_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Budget      = "1000-usd-monthly"
      Region      = "primary"
    }
  }
}

# Secondary region provider for HA
provider "aws" {
  alias  = "secondary"
  region = var.secondary_region
  
  default_tags {
    tags = {
      Service     = var.service_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Budget      = "1000-usd-monthly"
      Region      = "secondary"
    }
  }
}

# European region provider (optional)
provider "aws" {
  alias  = "europe"
  region = var.europe_region
  
  default_tags {
    tags = {
      Service     = var.service_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Budget      = "1000-usd-monthly"
      Region      = "europe"
    }
  }
}
