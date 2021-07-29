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
### Getting the JitBit details
#-------------------------------------------------------------
data "terraform_remote_state" "jitbit" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "jitbit/jitbit/terraform.tfstate"
    region = var.region
  }
}
