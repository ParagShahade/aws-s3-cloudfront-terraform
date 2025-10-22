# YouTube-like Service Infrastructure
# Budget: $1000/month
# Services: Lambda, SNS, CloudWatch, IAM

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
