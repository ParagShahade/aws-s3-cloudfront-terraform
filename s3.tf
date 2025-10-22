# S3 Buckets for Video Storage with HA

# Random ID for bucket suffix
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Primary S3 Bucket for video storage
resource "aws_s3_bucket" "video_storage_primary" {
  provider = aws.primary
  bucket   = "${var.service_name}-videos-primary-${random_id.bucket_suffix.hex}"
}

# Secondary S3 Bucket for HA (conditional)
resource "aws_s3_bucket" "video_storage_secondary" {
  count    = var.enable_ha ? 1 : 0
  provider = aws.secondary
  bucket   = "${var.service_name}-videos-secondary-${random_id.bucket_suffix.hex}"
}

# European S3 Bucket for HA/DR (optional)
resource "aws_s3_bucket" "video_storage_europe" {
  count    = var.enable_europe ? 1 : 0
  provider = aws.europe
  bucket   = "${var.service_name}-videos-eu-${random_id.bucket_suffix.hex}"
}

# Primary S3 Bucket versioning
resource "aws_s3_bucket_versioning" "video_storage_primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.video_storage_primary.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Secondary S3 Bucket versioning (conditional)
resource "aws_s3_bucket_versioning" "video_storage_secondary" {
  count    = var.enable_ha ? 1 : 0
  provider = aws.secondary
  bucket   = aws_s3_bucket.video_storage_secondary[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# European S3 Bucket versioning (conditional)
resource "aws_s3_bucket_versioning" "video_storage_europe" {
  count    = var.enable_europe ? 1 : 0
  provider = aws.europe
  bucket   = aws_s3_bucket.video_storage_europe[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# Primary S3 Bucket lifecycle for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "video_storage_primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.video_storage_primary.id

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

# Secondary S3 Bucket lifecycle (conditional)
resource "aws_s3_bucket_lifecycle_configuration" "video_storage_secondary" {
  count    = var.enable_ha ? 1 : 0
  provider = aws.secondary
  bucket   = aws_s3_bucket.video_storage_secondary[0].id

  rule {
    id     = "cost_optimization"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# European S3 Bucket lifecycle (conditional)
resource "aws_s3_bucket_lifecycle_configuration" "video_storage_europe" {
  count    = var.enable_europe ? 1 : 0
  provider = aws.europe
  bucket   = aws_s3_bucket.video_storage_europe[0].id

  rule {
    id     = "cost_optimization"
    status = "Enabled"

    filter {}

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Cross-region replication (conditional)
resource "aws_s3_bucket_replication_configuration" "replication" {
  count  = var.enable_ha ? 1 : 0
  provider = aws.primary
  bucket = aws_s3_bucket.video_storage_primary.id
  role   = aws_iam_role.replication[0].arn

  rule {
    id     = "replicate_to_secondary"
    status = "Enabled"
    
    destination {
      bucket        = aws_s3_bucket.video_storage_secondary[0].arn
      storage_class = "STANDARD"
    }
  }
}

# IAM role for replication
resource "aws_iam_role" "replication" {
  count = var.enable_ha ? 1 : 0
  provider = aws.primary
  name = "${var.service_name}-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for replication
resource "aws_iam_role_policy" "replication" {
  count = var.enable_ha ? 1 : 0
  provider = aws.primary
  name = "${var.service_name}-replication-policy"
  role = aws_iam_role.replication[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.video_storage_primary.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ReplicateObject",
          "s3:ReplicateDelete",
          "s3:ReplicateTags"
        ]
        Resource = "${aws_s3_bucket.video_storage_secondary[0].arn}/*"
      }
    ]
  })
}

# Public access block for EU bucket (conditional)
resource "aws_s3_bucket_public_access_block" "video_storage_europe" {
  count    = var.enable_europe ? 1 : 0
  provider = aws.europe
  bucket   = aws_s3_bucket.video_storage_europe[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Primary S3 Bucket public access block
resource "aws_s3_bucket_public_access_block" "video_storage_primary" {
  provider = aws.primary
  bucket   = aws_s3_bucket.video_storage_primary.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Secondary S3 Bucket public access block (conditional)
resource "aws_s3_bucket_public_access_block" "video_storage_secondary" {
  count    = var.enable_ha ? 1 : 0
  provider = aws.secondary
  bucket   = aws_s3_bucket.video_storage_secondary[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
