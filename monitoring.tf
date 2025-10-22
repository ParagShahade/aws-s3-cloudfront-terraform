# Enhanced Monitoring with HA Support

# SNS Topic for cost alerts
resource "aws_sns_topic" "cost_alerts" {
  provider = aws.primary
  name     = "${var.service_name}-cost-alerts"
}

# Email subscription for cost alerts
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.alert_email != "" ? 1 : 0
  provider  = aws.primary
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Billing Alarm - Warning at $900
resource "aws_cloudwatch_metric_alarm" "billing_warning" {
  provider            = aws.primary
  alarm_name          = "${var.service_name}-billing-warning"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400"
  statistic           = "Maximum"
  threshold           = "900"
  alarm_description   = "Cost warning at $900"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    Currency = "USD"
  }
}

# S3 Health Monitoring - Primary
resource "aws_cloudwatch_metric_alarm" "s3_primary_health" {
  provider            = aws.primary
  alarm_name          = "${var.service_name}-s3-primary-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "Primary S3 bucket health check"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    BucketName = aws_s3_bucket.video_storage_primary.bucket
  }
}

# S3 Health Monitoring - Secondary (conditional)
resource "aws_cloudwatch_metric_alarm" "s3_secondary_health" {
  count               = var.enable_ha ? 1 : 0
  provider            = aws.secondary
  alarm_name          = "${var.service_name}-s3-secondary-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "Secondary S3 bucket health check"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    BucketName = aws_s3_bucket.video_storage_secondary[0].bucket
  }
}

# S3 Health Monitoring - Europe (conditional)
resource "aws_cloudwatch_metric_alarm" "s3_europe_health" {
  count               = var.enable_europe ? 1 : 0
  provider            = aws.europe
  alarm_name          = "${var.service_name}-s3-europe-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "European S3 bucket health check"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    BucketName = aws_s3_bucket.video_storage_europe[0].bucket
  }
}

# CloudFront Health Monitoring
resource "aws_cloudwatch_metric_alarm" "cloudfront_health" {
  provider            = aws.primary
  alarm_name          = "${var.service_name}-cloudfront-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "4xxErrorRate"
  namespace           = "AWS/CloudFront"
  period              = "300"
  statistic           = "Average"
  threshold           = "5.0"
  alarm_description   = "CloudFront distribution health check"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    DistributionId = aws_cloudfront_distribution.video_distribution.id
  }
}

# Replication Monitoring (conditional)
resource "aws_cloudwatch_metric_alarm" "replication_health" {
  count               = var.enable_ha ? 1 : 0
  provider            = aws.primary
  alarm_name          = "${var.service_name}-replication-health"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ReplicationLatency"
  namespace           = "AWS/S3"
  period              = "300"
  statistic           = "Average"
  threshold           = "300"  # 5 minutes
  alarm_description   = "S3 cross-region replication latency"
  alarm_actions       = [aws_sns_topic.cost_alerts.arn]

  dimensions = {
    BucketName = aws_s3_bucket.video_storage_primary.bucket
  }
}
