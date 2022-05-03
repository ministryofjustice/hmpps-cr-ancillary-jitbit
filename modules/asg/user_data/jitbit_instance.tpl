<powershell>

$ErrorActionPreference = "Continue"
$VerbosePreference="Continue"

$instanceId = Invoke-Restmethod -uri http://169.254.169.254/latest/meta-data/instance-id
$ad_username = Get-SSMParameter -Name /${common_name}/jitbit/ad/service_account/username
$ad_password = Get-SSMParameter -Name /${common_name}/jitbit/ad/service_account/password -WithDecryption $true

Write-Output "------------------------------------"
Write-Output "$(get-date) Install latest SSM Agent"
Write-Output "------------------------------------"
$ssmServiceInstalled = get-service | where name -eq "AmazonSSMAgent"  
if  ( ! $ssmServiceInstalled ) {
    Invoke-WebRequest https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile $env:USERPROFILE\Desktop\SSMAgent_latest.exe
    Start-Process -FilePath $env:USERPROFILE\Desktop\SSMAgent_latest.exe -ArgumentList "/S"
} else {
    Write-Output "SSM Agent already installed"
} 

Write-Output "------------------------------------"
Write-Output "$(get-date) Install Chocolatey & Carbon"
Write-Output "------------------------------------"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
}
choco install carbon -y --version 2.9.2

Write-Output "------------------------------------"
Write-Output "$(get-date) Install AD Client and DNS Client Tools"
Write-Output "------------------------------------"
Install-WindowsFeature RSAT-ADDS
Install-WindowsFeature RSAT-DNS-Server

Write-Output "----------------------------------------------"
Write-Output "$(get-date) Run all scripts that apply runtime config"
Write-Output "----------------------------------------------"
$runtimeconfig = 'c:\setup\runtimeconfig'
Get-ChildItem $runtimeconfig -Filter *.ps1 | 
    Foreach-Object {
        & $runtimeconfig\$_
    }

Write-Output "------------------------------------"
Write-Output "$(get-date) Auto Add to AD"
Write-Output "------------------------------------"
try {
    $isDomainJoined = get-ssmassociation -Name "${ssm_adjoin_document_name}" -InstanceId $instanceId
} catch {
    $isDomainJoined = $false
}

if (! $isDomainJoined) {
    Set-DefaultAWSRegion -Region eu-west-2
    New-SSMAssociation -InstanceId $instanceId -Name "${ssm_adjoin_document_name}"
} else {
    Write-Output "Instance has already been added to AD"
} 

Write-Output "------------------------------------"
Write-Output "$(get-date) Map FSX"
Write-Output "------------------------------------"
$driveMappedToFsx = Get-SmbGlobalMapping 
if (! $driveMappedToFsx) {
    $secpasswd = ConvertTo-SecureString $ad_password.Value -AsPlainText -Force
    $domaincreds = New-Object System.Management.Automation.PSCredential ($ad_username.Value, $secpasswd) 
    New-SmbGlobalMapping -RemotePath "\\${filesystem_dns_name}\Share" -Persistent $true -Credential $domaincreds -LocalPath D:
} else {
    Write-Output "Drive has already been mapped to Fsx"
}


Write-Output "------------------------------------"
Write-Output "$(get-date) Install IIS"
Write-Output "------------------------------------"
Install-WindowsFeature Web-Server -IncludeManagementTools -IncludeAllSubFeature
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module -Name IISAdministration -Force

Remove-IISSite -Name "Default Web Site" -Confirm:$false -Verbose

Write-Output "------------------------------------"
Write-Output "$(get-date) Install other dependencies - the .NET core hosting bundle"
Write-Output "------------------------------------"
Copy-S3Object -BucketName "${config_bucket}" -Key installers/dotnet-hosting-6.0.4-win.exe -LocalFile C:\Setup\DotNetHostingBundle\dotnet-hosting-6.0.4-win.exe
& C:\Setup\DotNetHostingBundle\dotnet-hosting-6.0.4-win.exe /install /quiet /log C:\Setup\DotNetHostingBundle\install.log
net stop was /y
net start w3svc

Write-Output "------------------------------------"
Write-Output "$(get-date) Install Jitbit Helpdesk site"
Write-Output "------------------------------------"

$jitbitSiteInstalled = get-iissite | where name -eq JitBit
if ( ! $jitbitSiteInstalled) {
    Copy-S3Object -BucketName "${config_bucket}" -KeyPrefix ${installer_files_s3_prefix}/HelpDesk -LocalFolder C:\inetpub\wwwroot\HelpDesk 
    New-SelfSignedCertificate -DnsName localhost -CertStoreLocation cert:\LocalMachine\My -NotAfter (Get-Date).AddYears(3)
    $cert = (Get-ChildItem cert:\LocalMachine\My | where-object { $_.Subject -like "*localhost*" } | Select-Object -First 1).Thumbprint
    New-IISSite -Name "JitBit" -PhysicalPath "C:\inetpub\wwwroot\HelpDesk" -BindingInformation "*:443:" -CertificateThumbPrint $cert -CertStoreLocation "Cert:\LocalMachine\My" -Protocol https
} else {
    Write-Output "Jitbit site has already been installed"
}

Write-Output "------------------------------------"
Write-Output "$(get-date) Install & Config Cloudwatch"
Write-Output "------------------------------------"
New-Item C:\cloudwatch_installer -ItemType Directory -ErrorAction Ignore
Invoke-WebRequest -Uri 'https://s3.amazonaws.com/amazoncloudwatch-agent/windows/amd64/latest/amazon-cloudwatch-agent.msi' -OutFile 'C:\cloudwatch_installer\amazon-cloudwatch-agent.msi'
Copy-S3Object -BucketName "${config_bucket}" -Key "${cloudwatch_config}" -LocalFile "C:\cloudwatch_installer\config.json"
Start-Process msiexec.exe -Wait -ArgumentList '/i C:\cloudwatch_installer\amazon-cloudwatch-agent.msi'
cd 'C:\Program Files\Amazon\AmazonCloudWatchAgent'
.\amazon-cloudwatch-agent-ctl.ps1 -a fetch-config -m ec2 -c file:C:\cloudwatch_installer\config.json -s
rm -r C:\cloudwatch_installer

Write-Output "------------------------------------"
Write-Output "$(get-date) Install & Config Log Rotation"
Write-Output "------------------------------------"
$User     = "${common_name}" + '\' + $ad_username.Value
$Password = $ad_password.Value
Add-LocalGroupMember -Group "Administrators" -Member $User
New-Item C:\mgmt -ItemType Directory -ErrorAction Ignore
Copy-S3Object -BucketName "${config_bucket}" -KeyPrefix mgmt -LocalFolder C:\mgmt
Register-ScheduledTask -TaskName "jitbit_log_rotation" -Xml (Get-Content "C:\mgmt\iis_log_rotation.xml" | Out-String)  -Force -User $User -Password $Password

Write-Output "------------------------------------"
Write-Output "$(get-date) Adding Service Management Team"
Write-Output "------------------------------------"
Add-LocalGroupMember -Group "Administrators" -Member "$common_name\ServiceMgmt"

</powershell>
<persist>true</persist>