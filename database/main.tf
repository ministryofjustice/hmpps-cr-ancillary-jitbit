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
## Getting the rds db password
#-------------------------------------------------------------
data "aws_ssm_parameter" "db_user" {
  name = "${var.cr_jitbit_rds_config["credentials_ssm_path"]}/user"
}

data "aws_ssm_parameter" "db_password" {
  name = "${var.cr_jitbit_rds_config["credentials_ssm_path"]}/password"
}
