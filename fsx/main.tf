#-------------------------------------------------------------
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "jitbit/common/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the ad admin password
#-------------------------------------------------------------
data "aws_ssm_parameter" "ad_admin_password" {
  name = "/cr-ancillary/jitbit/ad/admin/password"
}
