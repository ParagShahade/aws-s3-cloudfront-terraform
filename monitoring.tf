# Simple Cost Monitoring

# SNS Topic for cost alerts
resource "aws_sns_topic" "cost_alerts" {
  name = "${var.service_name}-cost-alerts"
}

# Email subscription for cost alerts
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.cost_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# CloudWatch Billing Alarm - Warning at $900
resource "aws_cloudwatch_metric_alarm" "billing_warning" {
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
