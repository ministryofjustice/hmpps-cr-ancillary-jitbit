<powershell>

$ErrorActionPreference = "Continue"
$VerbosePreference="Continue"

Write-Output "------------------------------------"
Write-Output "Install Chocolatey & Carbon"
Write-Output "------------------------------------"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}
choco install carbon -y --version 2.9.2

Write-Output "------------------------------------"
Write-Output "Install AD Client and DNS Client Tools"
Write-Output "------------------------------------"
Install-WindowsFeature RSAT-ADDS
Install-WindowsFeature RSAT-DNS-Server

Write-Output "----------------------------------------------"
Write-Output " Run all scripts that apply runtime config"
Write-Output "----------------------------------------------"
$runtimeconfig = 'c:\setup\runtimeconfig'
Get-ChildItem $runtimeconfig -Filter *.ps1 | 
    Foreach-Object {
        & $runtimeconfig\$_
    }

Write-Output "------------------------------------"
Write-Output "Auto Add to AD"
Write-Output "------------------------------------"
Set-DefaultAWSRegion -Region eu-west-2
Set-Variable -name instance_id -value (Invoke-Restmethod -uri http://169.254.169.254/latest/meta-data/instance-id)
New-SSMAssociation -InstanceId $instance_id -Name "${ssm_adjoin_document_name}"

Write-Output "------------------------------------"
Write-Output "Map FSX"
Write-Output "------------------------------------"
$ad_admin_password = Get-SSMParameter -Name /cr-ancillary/jitbit/ad/admin/password -WithDecryption $true
$secpasswd = ConvertTo-SecureString $ad_admin_password.Value -AsPlainText -Force
$domainusername = "admin"
$domaincreds = New-Object System.Management.Automation.PSCredential ($domainusername, $secpasswd) 

New-SmbGlobalMapping -RemotePath "\\${filesystem_dns_name}\Share" -Persistent $true -Credential $domaincreds -LocalPath D:

Write-Output "------------------------------------"
Write-Output "Install & Config IIS"
Write-Output "------------------------------------"
Install-WindowsFeature Web-Server -IncludeManagementTools -IncludeAllSubFeature
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name IISAdministration -Force

Remove-IISSite -Name "Default Web Site" -Confirm:$false -Verbose

Copy-S3Object -BucketName "${config_bucket}" -KeyPrefix installers\HelpDesk -LocalFolder C:\inetpub\wwwroot\HelpDesk

New-IISSite -Name "JitBit" -PhysicalPath "C:\inetpub\wwwroot\HelpDesk" -BindingInformation "*:80:"

Write-Output "------------------------------------"
Write-Output "Install & Config Cloudwatch"
Write-Output "------------------------------------"
New-Item C:\cloudwatch_installer -ItemType Directory -ErrorAction Ignore
Invoke-WebRequest -Uri 'https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi' -OutFile 'C:\cloudwatch_installer\amazon-cloudwatch-agent.msi'
Copy-S3Object -BucketName "${config_bucket}" -Key "${cloudwatch_config}" -LocalFile "C:\cloudwatch_installer\config.json"
Start-Process msiexec.exe -Wait -ArgumentList '/i C:\cloudwatch_installer\amazon-cloudwatch-agent.msi'
cd 'C:\Program Files\Amazon\AmazonCloudWatchAgent'
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:C:\cloudwatch_installer\config.json -s
rm -r C:\cloudwatch_installer

</powershell>
<persist>true</persist>