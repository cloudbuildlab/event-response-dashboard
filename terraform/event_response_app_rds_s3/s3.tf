# -----------------------------------------------------------------------------
# S3 bucket - fully managed
# -----------------------------------------------------------------------------

resource "random_id" "s3_suffix" {
  byte_length = 4
}

locals {
  s3_bucket_name = "${var.s3_bucket_prefix}-${var.environment}-${local.app_name}-${data.aws_caller_identity.current.account_id}-${random_id.s3_suffix.hex}"
}

resource "aws_s3_bucket" "app" {
  bucket        = local.s3_bucket_name
  force_destroy = var.s3_force_destroy
  tags          = merge(var.tags, { Name = local.s3_bucket_name })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "app" {
  bucket                  = aws_s3_bucket.app.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
