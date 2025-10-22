# Simple YouTube-like Service on AWS

A simple, cost-effective video hosting service built on AWS using S3 and CloudFront, designed to stay within a $1000/month budget.

## Architecture Overview

![AWS Video Delivery & Cost Monitoring Architecture](aws_arch.png)

This infrastructure provides:
- **S3 Storage**: Cost-optimized video storage with lifecycle policies
- **CloudFront CDN**: Global content delivery with caching
- **Cost Monitoring**: Basic cost alerts via email

## Features

### Video Storage & Delivery
- S3 bucket with lifecycle policies (Standard → IA → Glacier)
- CloudFront distribution for global content delivery
- Optimized caching for video content
- Secure access via CloudFront only

### Cost Optimization
- S3 lifecycle policies to reduce storage costs
- CloudFront Price Class 100 (North America + Europe only)
- Automatic cleanup of incomplete uploads

### Monitoring & Alerts
- CloudWatch billing alarm at $900 threshold
- SNS email notifications for cost alerts

## Cost Estimation (Monthly)

Based on typical usage patterns:

| Service | Estimated Cost | Notes |
|---------|----------------|-------|
| S3 Storage (1TB) | $23-50 | Depends on storage class distribution |
| S3 Requests | $5-15 | Based on upload/download frequency |
| CloudFront | $85-200 | Depends on data transfer volume |
| SNS | $1-5 | Alert notifications |
| **Total** | **$114-270** | Well within $1000 budget |

*Note: Costs scale with usage. The lifecycle policies help keep storage costs low.*

## Prerequisites

1. **AWS Account** with appropriate permissions
2. **Terraform** >= 1.0 installed
3. **AWS CLI** configured with credentials

## Quick Start

1. **Clone and Setup**
   ```bash
   git clone <repository>
   cd aws-cloudfront
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Configure Variables**
   Edit `terraform.tfvars` with your settings:
   ```hcl
   aws_region = "us-east-1"
   alert_email = "your-email@domain.com"
   service_name = "my-video-service"
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

4. **Configure Alerts**
   - Check your email for SNS subscription confirmation

## Configuration Options

### Required Variables
- `aws_region`: AWS region for deployment
- `service_name`: Unique name for your service

### Optional Variables
- `alert_email`: Email for cost alerts

## Usage

### Uploading Videos

Upload videos directly to S3 bucket using AWS CLI or SDK:

```bash
aws s3 cp my-video.mp4 s3://your-bucket-name/videos/
```

### Accessing Videos

Videos are served via CloudFront:
```
https://your-cloudfront-domain/videos/filename.mp4
```

### Monitoring Costs

- Email notifications when costs exceed $900
- Check AWS Billing dashboard for detailed costs

## Security Considerations

### Access Control
- S3 bucket is private (no public access)
- CloudFront OAC for secure S3 access
- Videos only accessible via CloudFront

## Cost Optimization Tips

1. **Storage Lifecycle**
   - Videos automatically transition to cheaper storage classes
   - Incomplete uploads are cleaned up

2. **CloudFront Caching**
   - Videos cached at edge locations
   - Reduces S3 requests and data transfer

3. **Monitoring**
   - Email alerts when costs approach budget
   - Regular cost reviews via AWS console

## Troubleshooting

### Common Issues

1. **SNS Email Not Confirmed**
   - Check email for subscription confirmation
   - Confirm subscription before testing alerts

2. **CloudFront Distribution Slow**
   - Distribution takes 15-20 minutes to deploy
   - Check CloudFront console for status

3. **S3 Access Denied**
   - Verify bucket policies
   - Ensure CloudFront OAC is configured

## Cleanup

To destroy all resources:
```bash
terraform destroy
```

**Warning**: This will delete all videos and data. Ensure you have backups if needed.

## License

This project is provided as-is for educational and development purposes.
