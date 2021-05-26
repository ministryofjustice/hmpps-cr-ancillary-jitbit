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
# Install AD Client and DNS Client Tools
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

</powershell>
<persist>true</persist>