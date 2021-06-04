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
### Getting the database details
#-------------------------------------------------------------
data "terraform_remote_state" "database" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "jitbit/database/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the Monitoring details
#-------------------------------------------------------------
data "terraform_remote_state" "monitoring" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "monitoring/terraform.tfstate"
    region = var.region
  }
}
