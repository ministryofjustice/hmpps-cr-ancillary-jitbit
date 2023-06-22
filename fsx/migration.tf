resource "aws_iam_role" "datasync_s3_role" {
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

  name = "${var.environment_name}-datasync-transfer-to-s3"
  path = "/"

  assume_role_policy = data.aws_iam_policy_document.datasync_s3_trust[count.index].json
}

# Create the trust policy to allow DataSync to access the datasync_s3_role:
data "aws_iam_policy_document" "datasync_s3_trust" {
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

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
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

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
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

  name   = "${var.environment_name}-datasync_s3_policy"
  policy = data.aws_iam_policy_document.datasync_s3_access[count.index].json
}

# Attach policy to the role
resource "aws_iam_policy_attachment" "datasync_s3_attachment" {
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

  name       = "${var.environment_name}-datasync_s3_attachment"
  roles      = [aws_iam_role.datasync_s3_role[count.index].name]
  policy_arn = aws_iam_policy.datasync_s3_policy[count.index].arn
}

resource "aws_datasync_location_s3" "bucket_location" {
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

  s3_bucket_arn = "arn:aws:s3:::${local.fsx.migration_bucket_names[var.environment_name]}"
  subdirectory  = ""

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_s3_role[count.index].arn
  }
}

resource "aws_datasync_location_fsx_windows_file_system" "fsx_location" {
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

  fsx_filesystem_arn  = module.fsx.fsx.file_system_arn
  subdirectory        = "/share/OfficeAdmin/"
  user                = "admin"
  password            = data.aws_ssm_parameter.ad_admin_password.value
  security_group_arns = [module.fsx.fsx.security_group_arn]
}

resource "aws_datasync_task" "fsx_to_s3_migration" {
  count = contains(["cr-jitbit-dev", "cr-jitbit-training"], var.environment_name) ? 1 : 0

  destination_location_arn = aws_datasync_location_s3.bucket_location[count.index].arn
  name                     = "${var.environment_name}-fsx_to_s3_migration"
  source_location_arn      = aws_datasync_location_fsx_windows_file_system.fsx_location[count.index].arn

  options {
      atime                  = "BEST_EFFORT"
      bytes_per_second       = -1
      gid                    = "NONE"
      mtime                  = "PRESERVE"
      posix_permissions      = "NONE"
      preserve_deleted_files = "PRESERVE"
      preserve_devices       = "NONE"
      uid                    = "NONE"
      verify_mode            = "POINT_IN_TIME_CONSISTENT"
  }
}
