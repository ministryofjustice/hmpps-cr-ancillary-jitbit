data "template_file" "iam" {
  template = file("../policies/jitbit_instance.json")
  vars = {
    config_bucket_arn = local.bucket_arn
  }
}

module "iam-app-role" {
  source     = "../modules/iam/iam_role"
  rolename   = format("%s-instance", local.common_name)
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
