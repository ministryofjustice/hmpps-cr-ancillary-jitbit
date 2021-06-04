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

locals {
  common_name = data.terraform_remote_state.common.outputs.common_name
  tags        = data.terraform_remote_state.common.outputs.tags
}
