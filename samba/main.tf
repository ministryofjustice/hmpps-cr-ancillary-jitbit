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
### Getting the common details
#-------------------------------------------------------------
data "terraform_remote_state" "efs" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "jitbit/efs/terraform.tfstate"
    region = var.region
  }
}

#-------------------------------------------------------------
### S3 service name
#-------------------------------------------------------------
data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

#-------------------------------------------------------------
### Route tables
#-------------------------------------------------------------
data "aws_route_tables" "routes" {
  vpc_id = local.vpc_id

  filter {
    name   = "tag:Name"
    values = ["*private*"]
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
    values = ["HMPPS Base Docker Centos*"]
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
### Getting SSM creds
#-------------------------------------------------------------

# data "aws_ssm_parameter" "storage_password" {
#   name = "/cr-ancillary/jitbit/aws/storage/gateway/guest"
# }

#-------------------------------------------------------------
### Getting the vpc details
#-------------------------------------------------------------
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket_name
    key    = "vpc/terraform.tfstate"
    region = var.region
  }
}
