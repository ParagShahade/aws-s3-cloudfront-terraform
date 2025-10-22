# HA-Enabled Outputs

output "s3_bucket_primary_name" {
  description = "Name of the primary S3 bucket for video storage"
  value       = aws_s3_bucket.video_storage_primary.bucket
}

output "s3_bucket_secondary_name" {
  description = "Name of the secondary S3 bucket for HA (if enabled)"
  value       = var.enable_ha ? aws_s3_bucket.video_storage_secondary[0].bucket : null
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.video_distribution.domain_name
}

output "cloudfront_url" {
  description = "URL of the CloudFront distribution"
  value       = "https://${aws_cloudfront_distribution.video_distribution.domain_name}"
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for cost alerts"
  value       = aws_sns_topic.cost_alerts.arn
}

output "ha_enabled" {
  description = "Whether high availability is enabled"
  value       = var.enable_ha
}

output "primary_region" {
  description = "Primary AWS region"
  value       = var.aws_region
}

output "secondary_region" {
  description = "Secondary AWS region for HA"
  value       = var.enable_ha ? var.secondary_region : null
}

output "aws_account_id" {
  description = "AWS Account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS Region"
  value       = data.aws_region.current.name
}
