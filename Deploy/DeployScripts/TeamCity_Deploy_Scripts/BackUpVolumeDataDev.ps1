Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$ServerBackupFolderPath= $ServerBackupPath +"\TC_VOLUMES_"+ $CurrentDate + "_" + $BuildNumber,
[String]$ServerContentsPath="D:\TC_VOLUMES\*"
)
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
    If(!(test-path -Path $args[1]))
{
    New-Item -ItemType Directory -Path $args[1]
}
New-Item -ItemType Directory -Path  $args[0]
Copy-Item $args[2] -recurse -Destination $args[0] -force
}-ArgumentList $ServerBackupFolderPath, $ServerBackupPath, $ServerContentsPath
Remove-PSSession -Session $Session
