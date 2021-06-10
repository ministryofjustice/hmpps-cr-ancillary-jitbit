source_code_versions = {
  bootstrap       = "centos"
  samba           = "0.1.0"
  samba_bootstrap = "0.4.0"
}

jitbit_admin_cidrs = [
  "81.134.202.29/32",  #Moj VPN
  "217.33.148.210/32", #Digital studio
]

jitbit_access_cidrs = [
  "195.59.75.0/24",    # ARK internet (DOM1)
  "194.33.192.0/25",   # ARK internet (DOM1)
  "194.33.193.0/25",   # ARK internet (DOM1)
  "194.33.196.0/25",   # ARK internet (DOM1)
  "194.33.197.0/25",   # ARK internet (DOM1)
]

# London Region not support yet, so metrics are not yet publised, can be enabled at later stage for Route53 endpoint monitor
jitbit_route53_healthcheck_access_cidrs = [
  "15.177.0.0/18",      # GLOBAL Region
  "54.251.31.128/26",   # ap-southeast-1 Region
  "54.255.254.192/26",  # ap-southeast-1 Region
  "176.34.159.192/26",  # eu-west-1 Region
  "54.228.16.0/26",     # eu-west-1 Region
  "107.23.255.0/26",    # us-east-1 Region
  "54.243.31.192/26",   # us-east-1 Region
]

jitbit_route53_healthcheck_access_ipv6_cidrs = [
  "2406:da18:7ff:f800::/53",    # ap-southeast-1 Region
  "2406:da18:fff:f800::/53",    # ap-southeast-1 Region
  "2a05:d018:fff:f800::/53",    # eu-west-1 Region
  "2a05:d018:7ff:f800::/53",    # eu-west-1 Region
  "2600:1f18:7fff:f800::/53",   # us-east-1 Region
  "2600:1f18:3fff:f800::/53",   # us-east-1 Region
]

mail_account = [
  "dtv.office@justice.gov.uk",
  "dtv.oakwood@justice.gov.uk",
  "dtv.external@justice.gov.uk",
  "dtv.ttg@justice.gov.uk",
  "dtv.recalls@justice.gov.uk",
  "dtv.precons@justice.gov.uk",
  "dtv.programmes@justice.gov.uk",
  "dtv.secureinfo@justice.gov.uk",
  "dtv.iom@justice.gov.uk",
]
