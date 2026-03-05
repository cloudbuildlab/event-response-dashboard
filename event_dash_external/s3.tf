# -----------------------------------------------------------------------------
# S3 bucket
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "app" {
  bucket        = local.s3_bucket_name
  force_destroy = var.force_destroy

  tags = merge(var.tags, { Name = local.s3_bucket_name })
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
