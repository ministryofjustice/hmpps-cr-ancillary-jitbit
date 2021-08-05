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
### Getting the fsx details
#-------------------------------------------------------------
data "terraform_remote_state" "fsx" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "jitbit/fsx/terraform.tfstate"
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
### Getting the current vpc
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the current natgateway
#-------------------------------------------------------------
data "terraform_remote_state" "natgateway" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "natgateway/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### Getting the latest amazon ami
#-------------------------------------------------------------

data "aws_ssm_parameter" "storage_ami" {
  name = "/aws/service/storagegateway/ami/FILE_S3/latest"
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["HMPPS Windows Server Base 2019 Ansible master*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = [local.account_id, "895523100917"] # MOJ
}

#-------------------------------------------------------------
### Getting the bastion details
#-------------------------------------------------------------
data "terraform_remote_state" "bastion" {
  backend = "s3"

  config = {
    bucket   = var.bastion_remote_state_bucket_name
    key      = "service-bastion/terraform.tfstate"
    region   = var.region
    role_arn = var.bastion_role_arn
  }
}

#-------------------------------------------------------------
## Getting the rds db password
#-------------------------------------------------------------
data "aws_ssm_parameter" "db_user_id" {
  name = "/${local.common_name}/jitbit/rds/jitbit/user/username"
}

data "aws_ssm_parameter" "db_user_password" {
  name = "/${local.common_name}/jitbit/rds/jitbit/user/password"
}
