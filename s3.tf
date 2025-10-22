# S3 Bucket for Video Storage

# S3 Bucket for video storage
resource "aws_s3_bucket" "video_storage" {
  bucket = "${var.service_name}-video-storage-${random_id.bucket_suffix.hex}"
}

# Random ID for bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket versioning
resource "aws_s3_bucket_versioning" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket lifecycle for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  rule {
    id     = "cost_optimization"
    status = "Enabled"

    filter {}

    # Move to cheaper storage after 30 days
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    # Move to Glacier after 90 days
    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    # Clean up incomplete uploads
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# S3 Bucket Policy for CloudFront access
resource "aws_s3_bucket_policy" "video_storage" {
  bucket = aws_s3_bucket.video_storage.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.video_storage.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.video_distribution.arn
          }
        }
      }
    ]
  })
}
