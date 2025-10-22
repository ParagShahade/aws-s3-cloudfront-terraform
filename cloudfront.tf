# CloudFront Distribution for Video Delivery

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "video_storage" {
  name                              = "${var.service_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "video_distribution" {
  origin {
    domain_name              = aws_s3_bucket.video_storage.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.video_storage.id
    origin_id                = "S3-${aws_s3_bucket.video_storage.bucket}"
  }

  enabled = true
  comment = "Video distribution"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.video_storage.bucket}"
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

  # Cache videos for 24 hours
  ordered_cache_behavior {
    path_pattern     = "videos/*"
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.video_storage.bucket}"
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
    max_ttl     = 86400
  }

  price_class = "PriceClass_100"  # North America + Europe only for cost savings

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
