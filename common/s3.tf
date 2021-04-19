# #-------------------------------------------
# ### S3 bucket for logs
# #--------------------------------------------
module "s3_lb_logs_bucket" {
  source         = "../modules/s3/s3bucket_without_policy"
  s3_bucket_name = "${local.common_name}-lb-logs"
  tags           = local.tags
  versioning     = false
}

data "template_file" "s3alb_logs_policy" {
  template = file("../policies/s3_alb_policy.json")

  vars = {
    s3_bucket_name   = module.s3_lb_logs_bucket.s3_bucket_name
    s3_bucket_prefix = "${local.common_name}-*"
    aws_account_id   = local.account_id
    lb_account_id    = local.lb_account_id
  }
}

module "s3alb_logs_policy" {
  source       = "../modules/s3/s3bucket_policy"
  s3_bucket_id = module.s3_lb_logs_bucket.s3_bucket_name
  policyfile   = data.template_file.s3alb_logs_policy.rendered
}
