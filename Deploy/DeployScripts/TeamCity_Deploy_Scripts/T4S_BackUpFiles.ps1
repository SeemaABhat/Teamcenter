Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$ServerBackupFolderPath= $ServerBackupPath + "\T4S_" + $CurrentDate + "_" + $BuildNumber+"\gs",
[String]$GitFileChangePath="SourceCode/Integration/T4S/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$ServerContentsPath=$HomePath +"*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "T4S files are modified, take backup of gs folder !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
    If(!(test-path -Path $args[0]))
{
    New-Item -ItemType Directory -Path $args[0]
}
Copy-Item $args[1] -recurse -Destination $args[0] -force
}-ArgumentList $ServerBackupFolderPath, $ServerContentsPath
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
}else{
write-host "No modification to T4S files, skip taking backup of gs folder !!"
}
