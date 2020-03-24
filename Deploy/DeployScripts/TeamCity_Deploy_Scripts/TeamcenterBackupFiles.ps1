Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[Parameter(Mandatory=$false)] [String]$DFSPath,
[Parameter(Mandatory=$false)] [String]$DFSServer,
[Parameter(Mandatory=$false)] [String]$envName,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$WorkflowPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Workflow_CopyFiles.ps1",
[String]$ServerBackupFolderPath= $ServerBackupPath + "\Teamcenter_" + $CurrentDate + "_" + $BuildNumber,
[String]$GitFileChangePath="SourceCode/Configuration/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$ServerContentsPath=$HomePath +"*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Teamcenter Configuration are modified, take backup of tcroot, tcdata & Volumne !!"
. $WorkflowPath
backupServerFiles $MultipleHostname $Username $Password $ServerContentsPath $ServerBackupFolderPath $DFSPath $DFSServer $envName
}else{
write-host "No modification to Teamcenter Configuration, skip taking backup of tcroot, tcdata & Volumne !!"
}
