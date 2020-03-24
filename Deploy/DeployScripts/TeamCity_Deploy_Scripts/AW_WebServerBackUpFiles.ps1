Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$JBossHomePathWeb,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$ServerBackupFolderPath= $ServerBackupPath + "\Web_" + $CurrentDate + "_" + $BuildNumber+"\deployments",
[String]$GitFileChangePath="SourceCode/Customization/AW/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$ServerFilesPath= $JBossHomePathWeb + "*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "AW files are modified, take backup of awc.war in Web server !!"

# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

Invoke-Command -Session $Session -ScriptBlock {
    If(!(test-path -Path $args[0]))
{
    New-Item -ItemType Directory -Path $args[0]
}
Copy-Item $args[1] -recurse -Destination $args[0] -force
}-ArgumentList $ServerBackupFolderPath, $ServerFilesPath
Remove-PSSession -Session $Session
}
}else{
write-host "No Modifications to AW, skip taking backup of awc.war in Web server !!"
}
