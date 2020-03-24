Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$DispatcherHomePath,
[Parameter(Mandatory=$false)] [String]$SwimHomePath,
[Parameter(Mandatory=$false)] [String]$JTHomePath,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$GitFileChangePath="SourceCode/Configuration/Dispatcher_Root/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$DisPatcherBackupFolderPath= $ServerBackupPath + "\Dispatcher_" + $CurrentDate + "_" + $BuildNumber,
[String]$SwimBackupFolderPath= $ServerBackupPath + "\SWIM_" + $CurrentDate + "_" + $BuildNumber,
[String]$JTPatcherBackupFolderPath= $ServerBackupPath + "\JTTranslators_" + $CurrentDate + "_" + $BuildNumber+"\SolidWorks_V18",
[String]$DisPatcherServerContentsPath=$DispatcherHomePath +"*",
[String]$SwimServerContentsPath=$SwimHomePath +"*",
[String]$JTServerContentsPath=$JTHomePath +"*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Dispatcher Server files are modified, Take backup of Dispatcher Home !!"
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
If(!(test-path -Path $args[2]))
{
    New-Item -ItemType Directory -Path $args[2]
}
Copy-Item $args[3] -recurse -Destination $args[2] -force
If(!(test-path -Path $args[4]))
{
    New-Item -ItemType Directory -Path $args[4]
}
Copy-Item $args[5] -recurse -Destination $args[4] -force
}-ArgumentList $DisPatcherBackupFolderPath, $DisPatcherServerContentsPath, $SwimBackupFolderPath,$SwimServerContentsPath, $JTPatcherBackupFolderPath,$JTServerContentsPath
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
}else{
write-host "No Modification to Dispatcher Server files, skip taking backup of Dispatcher Home !!"
}
