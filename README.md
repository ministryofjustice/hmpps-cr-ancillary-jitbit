# JitBit
## HMPPS Community Rehabilitation Ancillary Applications

JitBit Help Desk Ticketing System - Ticketing software for your support team

## Environment

The JitBit Help Desk Ticketing System is hosted in an AWS Account managed and run by MOJ.


|   Account Name      	| Account ID       	| Environment Config Label 	| Https Endpoint | Http Endpoint |
|--------- 	|------------------	|----------------	|----------------	| ----------------	| 
| hmpps-cr-jitbit-production	| 097456858629 	| [cr-jitbit-prod](https://github.com/ministryofjustice/hmpps-env-configs/tree/master/cr-jitbit-prod) 	| https://helpdesk.jitbit.cr.probation.service.justice.gov.uk/  |  http://helpdesk.jitbit.cr.probation.service.justice.gov.uk/ |
| hmpps-cr-jitbit-non-production    | 377957503799   	| [cr-jitbit-dev](https://github.com/ministryofjustice/hmpps-env-configs/tree/master/cr-jitbit-dev) 	| https://helpdesk.jitbit.dev.cr.probation.service.justice.gov.uk | http://helpdesk.jitbit.dev.cr.probation.service.justice.gov.uk/ |



![ia-diagram](./diagrams/JitBit_Community_Rehabilitation_Ancillary_Applications.svg)
The diagram above shows the current IA as deployed to meet MVP1 and 2*. The VPC consists of three groups of subnet spanning across three Availability Zones. Routing allows traffic for update etc out via NAT Gateway placed under each public subnet. Also, there is no route from the public subnet to the data subnet.

VPC subnets:

|         	| Account Name                    | eu-west-2a       	| eu-west-2b     	| eu-west-2c      	|
|---------	|-------------------------------- |------------------	|----------------	|------------------	|
| Public  	| hmpps-cr-jitbit-production      | 10.163.78.128/25	| 10.163.79.0/25	| 10.163.79.128/25 	|
| Private 	| hmpps-cr-jitbit-production      | 10.163.64.0/22  	| 10.163.68.0/22 	| 10.163.72.0/22   	|
| Data    	| hmpps-cr-jitbit-production      | 10.163.76.0/24   	| 10.163.77.0/24 	| 10.163.78.0/25   	|
| Public  	| hmpps-cr-jitbit-non-production  | 10.163.62.128/25 	| 10.163.63.0/25 	| 10.163.63.128/25 	|
| Private 	| hmpps-cr-jitbit-non-production  | 10.163.48.0/22  	| 10.163.52.0/22 	| 10.163.56.0/22   	|
| Data    	| hmpps-cr-jitbit-non-production  | 10.163.60.0/24  	| 10.163.61.0/24 	| 10.163.62.0/25   	|

## Service

Jitbit is a .net application where the binaries are provided to be directly referenced and use in IIS. The Application Instance is hosted as a part of Auto Scaling Group(ASG) where we mount FSx when any instance span up as part of the ASG will hold those binaries(Done as a part of one-time setup). 
Below are the list of version currently being used  
* Windows Server 2019 DataCenter
* IIS 10.0.17763.1
* SQL Server Standard Edition 15.00.4073.23.v1 (AWS RDS leveraged)

## Storage

One of the requirement for Jitbit is to have a local folder where email attachment are stored. Have leveraged FSx across Muti-AZ for it. Which lead to use the same for IIS binary as well to bring auto-recovery in place in case of AZ failure.
FSX requires Active directory(AD), have leveraged AWS Managed Microsoft AD. When an instance span  up within ASG, the instance are automatically joined to AD and FSx mapped.

## Backup

FSX is a fully managed file storage service which comes with managed backup and are configured nightly.
RDS leveraged for Database, automatic nightly backup are configured.

## Access

Each resource/service that support Security Groups(SGs) are configured to restrict egress and ingress. Allows only required traffic on specific port based on the rules.
Each resource/service that don't support SGs are configured with AD and access are restricted.
Credentials are store leveraging AWS Systems Manager Parameter Store.

## Email

AWS Simple Email Service (SES) has been configured to enable email notification from JitBit to user’s emails for ticket status, assignment etc.
AWS Work Mail has been configured as JitBit incoming mailboxes which can be used to open tickets and further communication updates(Currently setup in Ireland region and manually due to limitation in AWS Service offering and Terraform provider).

## Logging and Monitoring

Logs will be shipped to AWS Cloudwatch. Dashboards will be configured to show service performance. Alerts will be configured to inform of service degradation.