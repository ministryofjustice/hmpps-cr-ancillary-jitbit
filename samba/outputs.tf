output "storage_info" {
  value = {
    # dns_name = aws_vpc_endpoint.storage.dns_entry[0].dns_name
    bucket_name = module.s3bucket.s3_bucket_name
    # file_share_path = aws_storagegateway_smb_file_share.storage.path
    # public_ips = aws_instance.storage.*.public_ip
  }
}
