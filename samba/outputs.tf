output "storage_info" {
  value = {
    bucket_name              = module.s3bucket.s3_bucket_name
    bucket_arn               = module.s3bucket.s3_bucket_arn
    samba_host               = aws_elb.samba_lb.dns_name
    samba_security_group_id  = aws_security_group.lb.id
    samba_ssm_user           = local.samba_ssm_user
    samba_ssm_password       = local.samba_ssm_password
    samba_ssm_guest_password = local.jitbit_samba_configs["samba_ssm_guest_password"]
    storage_gateway_path     = aws_storagegateway_smb_file_share.storage.path
    storage_gateway_address  = "18.134.11.142" #hard code for now
  }
}
