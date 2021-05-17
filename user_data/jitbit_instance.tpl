<powershell>

$ErrorActionPreference = "Continue"
$VerbosePreference="Continue"

Write-Output "------------------------------------"
Write-Output "Auto Add to AD"
Write-Output "------------------------------------"
Set-DefaultAWSRegion -Region eu-west-2
Set-Variable -name instance_id -value (Invoke-Restmethod -uri http://169.254.169.254/latest/meta-data/instance-id)
New-SSMAssociation -InstanceId $instance_id -Name "${ssm_adjoin_document_name}"
</powershell>
<persist>true</persist>