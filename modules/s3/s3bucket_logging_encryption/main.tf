resource "aws_s3_bucket" "environment" {
  bucket = "${var.s3_bucket_name}"
  acl    = "${var.acl}"

  versioning {
    enabled = "${var.versioning}"
  }

  lifecycle {
    prevent_destroy = true
  }

  logging {
    target_bucket = "${var.target_bucket}"
    target_prefix = "${var.target_prefix}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${var.kms_master_key_id}"
        sse_algorithm     = "${var.sse_algorithm}"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    noncurrent_version_transition {
      days          = "${var.s3_lifecycle_config["noncurrent_version_transition_days"]}"
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_transition {
      days          = "${var.s3_lifecycle_config["noncurrent_version_transition_glacier_days"]}"
      storage_class = "GLACIER"
    }

    noncurrent_version_expiration {
      days = "${var.s3_lifecycle_config["noncurrent_version_expiration_days"]}"
    }
  }
  tags = "${merge(var.tags, map("Name", "${var.s3_bucket_name}"))}"
}

resource "aws_s3_bucket_metric" "environment" {
  bucket = "${aws_s3_bucket.environment.bucket}"
  name   = "EntireBucket"
}

resource "aws_s3_bucket_public_access_block" "environment" {
  bucket                  = aws_s3_bucket.environment.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
