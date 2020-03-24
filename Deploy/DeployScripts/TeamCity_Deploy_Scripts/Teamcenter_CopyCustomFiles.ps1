Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$TCityDeployPackPath= $RepoPath +"\SourceCode\Configuration\*",
[String]$GitFileChangePath="SourceCode/Configuration/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$BMIDERepoPath= $RepoPath + "\SourceCode\Configuration\BMIDE\output\wntx64\packaging\full_update\il9base_wntx64\*",
[String]$BMIDECopyPath= $DeployBackupPath + "\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\BMIDE\output\wntx64\packaging\full_update\il9base_wntx64",
[String]$ServerDeployBackupPath= $DeployBackupPath + "\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Teamcenter Configuration are modified, copy repo config files to server !!"
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
    If(!(test-path -Path $args[0]))
{
    New-Item -ItemType Directory -Path $args[0]
}
If(!(test-path -Path $args[1]))
{
    New-Item -ItemType Directory -Path $args[1]
}
}-ArgumentList $ServerDeployBackupPath, $BMIDECopyPath
# Above ends Remote Session.
write-host "BMIDECopyPath: " $BMIDECopyPath
write-host "BMIDERepoPath: " $BMIDERepoPath
Copy-Item -Path (Get-Item -Path $TCityDeployPackPath -Exclude ('BMIDE')).FullName -Destination $ServerDeployBackupPath -force -ToSession $Session -Recurse
Copy-Item $BMIDERepoPath -Destination $BMIDECopyPath -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}else{
write-host "No modification to Teamcenter Configuration, skip copying repo config files to server !!"
}
