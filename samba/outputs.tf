output "storage_info" {
  value = {
    # dns_name = aws_vpc_endpoint.storage.dns_entry[0].dns_name
    bucket_name = module.s3bucket.s3_bucket_name
    samba_host  = aws_elb.samba_lb.dns_name
    creds = {
      user     = local.samba_ssm_user,
      password = local.samba_ssm_password
    }
    # public_ips = aws_instance.storage.*.public_ip
  }
}
