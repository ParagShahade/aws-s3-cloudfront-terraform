# CloudFront Distribution for Video Delivery with HA

# CloudFront Origin Access Control for primary
resource "aws_cloudfront_origin_access_control" "video_storage_primary" {
  provider = aws.primary
  name                              = "${var.service_name}-oac-primary"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Origin Access Control for secondary (conditional)
resource "aws_cloudfront_origin_access_control" "video_storage_secondary" {
  count    = var.enable_ha ? 1 : 0
  provider = aws.secondary
  name                              = "${var.service_name}-oac-secondary"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution with multi-origin support
resource "aws_cloudfront_distribution" "video_distribution" {
  provider = aws.primary
  enabled  = true
  comment  = "HA Video distribution"

  # Primary origin
  origin {
    domain_name              = aws_s3_bucket.video_storage_primary.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.video_storage_primary.id
    origin_id                = "primary-s3"
  }

  # Secondary origin (conditional)
  dynamic "origin" {
    for_each = var.enable_ha ? [1] : []
    content {
      domain_name              = aws_s3_bucket.video_storage_secondary[0].bucket_regional_domain_name
      origin_access_control_id = aws_cloudfront_origin_access_control.video_storage_secondary[0].id
      origin_id                = "secondary-s3"
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "primary-s3"
    compress         = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # Cache videos for 24 hours with failover
  ordered_cache_behavior {
    path_pattern     = "videos/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.enable_ha ? "secondary-s3" : "primary-s3"
    compress         = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 86400
    max_ttl     = 31536000  # 1 year for better caching
  }

  price_class = var.cloudfront_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

# S3 Bucket Policy for primary CloudFront access
resource "aws_s3_bucket_policy" "video_storage_primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.video_storage_primary.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.video_storage_primary.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.video_distribution.arn
          }
        }
      }
    ]
  })
}

# S3 Bucket Policy for secondary CloudFront access (conditional)
resource "aws_s3_bucket_policy" "video_storage_secondary" {
  count    = var.enable_ha ? 1 : 0
  provider = aws.secondary
  bucket   = aws_s3_bucket.video_storage_secondary[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.video_storage_secondary[0].arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.video_distribution.arn
          }
        }
      }
    ]
  })
}
