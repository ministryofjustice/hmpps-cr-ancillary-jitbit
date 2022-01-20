Clear-Host

# In-line function to create an AD group
function CreateADGroup {
    
  param (
    [string]$ADGroupName
  )

  try {
       $group = Get-ADGroup -Identity $ADGroupName
       write-output "--- Group $ADGroupName already exists ---"
  }
  catch {
      write-output "---------------------------------------------------------------------------------"
      write-output "--- Creating AD Group $ADGroupName ---"

      $Description = "$ADGroupName users"
      New-ADGroup -Name $ADGroupName -SAMAccountName $ADGroupName -GroupCategory "Security" -GroupScope "Global" -DisplayName $ADGroupName -Description $Description
      write-output ""
  }
}

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
$domainname = $environmentName.Value


## Create the groups
$groups = @("ServiceMgmt")

write-output '================================================================================'
write-output " Creating groups in ${domainname}.local"
write-output '================================================================================'
foreach ($group in $groups) {
  Write-Output "Creating group ${group}"
  CreateADGroup $group
}