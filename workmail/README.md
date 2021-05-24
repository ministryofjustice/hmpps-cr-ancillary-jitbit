# WorkMail
* As of 21/May/2021 Terraform provider and london region dont support creation of WorkMail its setup manually through console
* Seperate Route53 for hosted zone entry created for inbound email to work with Work mail as SES configured to use default hosted zone
* SSM holds the WorkMail crendtails
* Ireland region is used to setup workmail