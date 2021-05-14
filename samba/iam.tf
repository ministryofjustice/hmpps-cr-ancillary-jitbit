data "template_file" "iam" {
  template = file("../policies/storage_instance.json")

  vars = {
    storage_bucket_arn = module.s3bucket.s3_bucket_arn
  }
}

module "iam-app-role" {
  source     = "../modules/iam/iam_role"
  rolename   = "${local.common_name}-storage-inst"
  policyfile = "ec2.json"
}

module "iam-instance-profile" {
  source = "../modules/iam/instance_profile"
  role   = module.iam-app-role.iamrole_name
}

module "iam-app-policy" {
  source     = "../modules/iam/rolepolicy"
  policyfile = data.template_file.iam.rendered
  rolename   = module.iam-app-role.iamrole_name
}
