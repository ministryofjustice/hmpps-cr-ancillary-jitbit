<powershell>

$ErrorActionPreference = "Continue"
$VerbosePreference="Continue"

Write-Output "------------------------------------"
Write-Output "Install latest SSM Agent"
Write-Output "------------------------------------"
Invoke-WebRequest https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/windows_amd64/AmazonSSMAgentSetup.exe -OutFile $env:USERPROFILE\Desktop\SSMAgent_latest.exe
Start-Process -FilePath $env:USERPROFILE\Desktop\SSMAgent_latest.exe -ArgumentList "/S"

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
Write-Output "Creating Local Admin Users"
Write-Output "------------------------------------"
Import-Module Carbon
$misCreds = New-Credential -UserName "${user}" -Password "${password}"
Install-User -Credential $misCreds
Add-GroupMember -Name Administrators -Member ${user}

Write-Output "------------------------------------"
# Install AD Client and DNS Client Tools
Write-Output "------------------------------------"
Install-WindowsFeature RSAT-ADDS
Install-WindowsFeature RSAT-DNS-Server

Write-Output "------------------------------------"
Write-Output "Resize Partition"
Write-Output "------------------------------------"
$MaxSize = (Get-PartitionSupportedSize -DriveLetter C).sizeMax
Resize-Partition -DriveLetter C -Size $MaxSize

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

</powershell>
<persist>true</persist>