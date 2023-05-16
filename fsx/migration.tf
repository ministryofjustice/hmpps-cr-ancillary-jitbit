#Create an IAM role called datasync_s3_role
resource "aws_iam_role" "datasync_s3_role" {
  name = "jitbit-datasync-transfer-to-s3"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.datasync_s3_trust.json
}

# Create the trust policy to allow DataSync to access the datasync_s3_role:
data "aws_iam_policy_document" "datasync_s3_trust" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["datasync.amazonaws.com"]
    }
  }
}

# Create the policy to allow DataSync to access S3
data "aws_iam_policy_document" "datasync_s3_access" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads"
    ]
    resources = ["arn:aws:s3:::${local.fsx.migration_bucket_names[var.environment_name]}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:ListMultipartUploadParts",
      "s3:GetObjectTagging",
      "s3:PutObjectTagging",
      "s3:PutObject"
    ]
    resources = ["arn:aws:s3:::${local.fsx.migration_bucket_names[var.environment_name]}/*"]
  }
}

resource "aws_iam_policy" "datasync_s3_policy" {
  name   = "datasync_s3_policy"
  policy = data.aws_iam_policy_document.datasync_s3_access.json
}

# Attach policy to the role
resource "aws_iam_policy_attachment" "datasync_s3_attachment" {
  name       = "datasync_s3_attachment"
  roles      = [aws_iam_role.datasync_s3_role.name]
  policy_arn = aws_iam_policy.datasync_s3_policy.arn
}

resource "aws_datasync_location_s3" "bucket_location" {
  s3_bucket_arn = "arn:aws:s3:::${local.fsx.migration_bucket_names[var.environment_name]}"
  subdirectory  = ""

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_role.arn
  }
}

resource "aws_datasync_location_fsx_windows_file_system" "fsx_location" {
  fsx_filesystem_arn  = module.fsx.fsx.file_system_arn
  subdirectory        = "/share/OfficeAdmin/"
  user                = "admin"
  password            = data.aws_ssm_parameter.ad_admin_password.value
  security_group_arns = [module.fsx.fsx.security_group_arn]
}

resource "aws_datasync_task" "fsx_to_s3_migration" {
  destination_location_arn = aws_datasync_location_s3.bucket_location.arn
  name                     = "fsx_to_s3_migration"
  source_location_arn      = aws_datasync_location_fsx_windows_file_system.fsx_location.arn

}
