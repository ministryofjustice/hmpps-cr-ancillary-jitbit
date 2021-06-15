Import-Module ActiveDirectory

Clear-Host

Write-Output '================================================================'
Write-Output ' Get environmentName, application variables from aws meta-data'
Write-Output '================================================================'

# Get the instance id from ec2 meta data
$instanceid = Invoke-RestMethod "http://169.254.169.254/latest/meta-data/instance-id"

# Get the environment name and application from this instance's environment-name and application tag values
$environmentName = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="environment-name"
        }
    )
$application = Get-EC2Tag -Filter @(
        @{
            name="resource-id"
            values="$instanceid"
        }
        @{
            name="key"
            values="sub-project"
        }
    )
$domain_name = "$($environmentName.Value).local"

write-output '================================================================================'
write-output " Creating Service Account JitBit"
write-output '================================================================================'

$svc_username_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/ad/service_account/username"
$svc_password_SSMPath = "/" + $environmentName.Value + "/" + $application.Value + "/ad/service_account/password"

Write-Output "Getting the Service Username from ${svc_username_SSMPath}"
$svc_username = Get-SSMParameter -Name $svc_username_SSMPath -WithDecryption $true

Write-Output "Getting the Service Password from ${svc_password_SSMPath}"
$svc_password = Get-SSMParameter -Name $svc_password_SSMPath -WithDecryption $true

$ServiceUsername = $svc_username.Value

# netbios names limit of 15 chars, less than that are not truncated
if($domainname.Length -gt 15) {
    $domainname = $domainname.SubString(0,15)
}

$OUPath = "OU=Users,OU=${domainname},DC=${domainname},DC=local"

Write-Output "Creating the user ${ServiceUsername} in '${OUPath}'"
$SecureAccountPassword = $svc_password.Value | ConvertTo-SecureString -AsPlainText -Force
New-ADUser -Name $ServiceUsername -GivenName $ServiceUsername -Surname "" -Path $OUPath -AccountPassword $SecureAccountPassword -Enabled $true -Description "JitBit Service Account"

Write-Output "Checking the AD for the newly created user ${ServiceUsername}"
Get-ADUser -Filter * -Properties SamAccountName | Where { $_.samAccountName -eq $ServiceUsername }

$AWSDelegateGroup = "CN=AWS Delegated Administrators,OU=AWS Delegated Groups,DC=${domainname},DC=local"

Write-Output "Adding User '$ServiceUsername' to group '$AWSDelegateGroup'"
Add-ADGroupMember -Identity $AWSDelegateGroup -Members $ServiceUsername
