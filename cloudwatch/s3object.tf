# synthetics screenshot location
resource "aws_s3_bucket_object" "synthetics" {
  bucket = local.common_name
  key    = "synthetics/"
  source = "/dev/null"
}
