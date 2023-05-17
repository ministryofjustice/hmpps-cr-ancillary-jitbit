resource "aws_iam_role" "datasync_s3_role" {
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

  name = "jitbit-datasync-transfer-to-s3"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.datasync_s3_trust[count.index].json
}

# Create the trust policy to allow DataSync to access the datasync_s3_role:
data "aws_iam_policy_document" "datasync_s3_trust" {
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

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
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

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
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

  name   = "datasync_s3_policy"
  policy = data.aws_iam_policy_document.datasync_s3_access[count.index].json
}

# Attach policy to the role
resource "aws_iam_policy_attachment" "datasync_s3_attachment" {
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

  name       = "datasync_s3_attachment"
  roles      = [aws_iam_role.datasync_s3_role[count.index].name]
  policy_arn = aws_iam_policy.datasync_s3_policy[count.index].arn
}

resource "aws_datasync_location_s3" "bucket_location" {
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

  s3_bucket_arn = "arn:aws:s3:::${local.fsx.migration_bucket_names[var.environment_name]}"
  subdirectory  = ""

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_role[count.index].arn
  }
}

resource "aws_datasync_location_fsx_windows_file_system" "fsx_location" {
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

  fsx_filesystem_arn  = module.fsx.fsx.file_system_arn
  subdirectory        = "/share/OfficeAdmin/"
  user                = "admin"
  password            = data.aws_ssm_parameter.ad_admin_password.value
  security_group_arns = [module.fsx.fsx.security_group_arn]
}

resource "aws_datasync_task" "fsx_to_s3_migration" {
  count = var.environment_name == "cr-jitbit-dev" ? 1 : 0

  destination_location_arn = aws_datasync_location_s3.bucket_location[count.index].arn
  name                     = "fsx_to_s3_migration"
  source_location_arn      = aws_datasync_location_fsx_windows_file_system.fsx_location[count.index].arn

}
