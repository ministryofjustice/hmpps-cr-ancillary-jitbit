# show commands for Fsx
# Get-Command -Module FSxRemoteAdmin

# https://docs.aws.amazon.com/fsx/latest/WindowsGuide/remote-pwrshell.html
# https://www.youtube.com/watch?v=vbnk4Ov9gL0

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
$domainName = $environmentName.Value

#============================================================
# Getting FSx FileSystem Powershell Endpoint via AWS Powershell
#============================================================
$FileSystem = Get-FsxFileSystem | ? {$_.Tags.Key -eq "sub-project" -and $_.Tags.Value -eq "jitbit"}
#$FileSystem
$FileSystemId = $FileSystem.FileSystemId
#Write-Output "FileSystemId: $FileSystemId"
$WindowsConfiguration = $FileSystem.WindowsConfiguration
#$WindowsConfiguration
$Tags = $FileSystem.Tags
#$Tags | ft *
$Endpoint = $FileSystem.WindowsConfiguration.RemoteAdministrationEndpoint
Write-Output "Powershell Endpoint: $Endpoint"

#============================================================
# Open a session to the target FSx Powershell endpoint
#============================================================
$Session = New-PSSession -ComputerName $Endpoint -ConfigurationName FSxRemoteAdmin

Import-PsSession $Session -AllowClobber
$Session

#============================================================
# The following commands run in the context of the Imported
# Session so are actually being run on the target FSx instance
#============================================================

# Get the FSx Share details
Get-FSxSmbShare -Name 'share'

# Get the File Share Permissions
Get-FSxSmbShareAccess -Name 'share'

# now grant permissions on the share
# Syntax same as https://docs.microsoft.com/en-us/powershell/module/smbshare/grant-smbshareaccess?view=win10-ps

# NT AUTHORITY\SYSTEM - MANDATORY permission
Grant-FSxSmbShareAccess -Name 'share' -AccountName 'NT AUTHORITY\SYSTEM' -AccessRight Full -Force

# cr-jitbit-dev\AWS Delegated Administrators
Grant-FSxSmbShareAccess -Name 'share' -AccountName "${domainName}\AWS Delegated Administrators"  -AccessRight Full -Force

# cr-jitbit-dev\jitbit
Grant-FSxSmbShareAccess -Name 'share' -AccountName "${domainName}\jitbit" -AccessRight Full -Force

# everyone
Revoke-FSxSmbShareAccess -Name 'share' -AccountName 'everyone' -Force

#============================================================
# Disconnect remote session
#============================================================
Disconnect-PsSession $Session
$Session