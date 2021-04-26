data "template_file" "iam" {
  template = file("../policies/samba_instance.json")

  vars = {}
}

module "iam-app-role" {
  source     = "../modules/iam/iam_role"
  rolename   = "${local.common_name}-samba"
  policyfile = "ec2_lambda.json"
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
