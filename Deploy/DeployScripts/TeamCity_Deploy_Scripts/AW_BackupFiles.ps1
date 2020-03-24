Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$DeployFilesPath= $DeployBackupPath + "\AW_" + $CurrentDate + "_" + $BuildNumber,
[String]$RepoDeployFilesPath=$RepoPath+"\SourceCode\Customization\AW\*",
[String]$ServerBackupFolderPath= $ServerBackupPath + "\AW_" + $CurrentDate + "_" + $BuildNumber+"\stage",
[String]$GitFileChangePath="SourceCode/Customization/AW/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$ServerContentsPath=$HomePath +"*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "AW files are modified, take backup of server files & copy custom files to server !!"
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
 If(!(test-path -Path $args[2]))
{
    New-Item -ItemType Directory -Path $args[2]
}
Copy-Item $args[1] -recurse -Destination $args[0] -force
}-ArgumentList $ServerBackupFolderPath, $ServerContentsPath, $DeployFilesPath
Copy-Item $RepoDeployFilesPath -Destination $DeployFilesPath -force -ToSession $Session -Recurse
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
}else{
write-host "No Modifications to AW, skip taking backup of server files & copying custom files to server !!"
}
