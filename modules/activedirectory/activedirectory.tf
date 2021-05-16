resource "aws_directory_service_directory" "active_directory" {
  name        = var.ad.name
  short_name  = var.ad.short_name 

  description = "Microsoft AD for ${var.common.environment_name}.local"
  
#   TO Do
  password    = var.ad.admin_password

  enable_sso  = false
  type        = "MicrosoftAD"
  edition     = "Standard"


  vpc_settings {
    vpc_id     = var.common.vpc_id
    subnet_ids = var.common.subnet_ids
  }

  tags = merge(
    var.common.tags,
    {
      "Name" = var.common.environment_name
    },
  )

  # Required as AWS does not allow you to change the Admin password post AD Create - you must destroy/recreate 
  # When we run tf plan against an already created AD it will always show the AD needs destroy/create so we ignore
  lifecycle {
    ignore_changes = [
      password
    ]
  }

}
