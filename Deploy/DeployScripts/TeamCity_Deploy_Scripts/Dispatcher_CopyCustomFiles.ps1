Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$DispatcherHomePath,
[Parameter(Mandatory=$false)] [String]$SwimHomePath,
[Parameter(Mandatory=$false)] [String]$JTHomePath,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$GitFileChangePath="SourceCode/Configuration/Dispatcher_Root/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$DispatcherRepoPath= $RepoPath +"\SourceCode\Configuration\Dispatcher_Root\*",
[String]$SwimRepoPath= $RepoPath +"\SourceCode\Configuration\SWIM\*",
[String]$JTRepoPath= $RepoPath +"\SourceCode\Configuration\JTTranslators\SolidWorks_V18\*",
[String]$DispatcherDeployBackupPath= $DeployBackupPath+"\Dispatcher_" + $CurrentDate + "_" + $BuildNumber
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Dispatcher Server files are modified, copy repo files to server !!"
# Remote Server.
Write-Host "Pool Manager ServiceName: " $PoolManagerServiceName
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
}-ArgumentList $DispatcherDeployBackupPath
Copy-Item $DispatcherRepoPath -Destination $DispatcherDeployBackupPath -force -ToSession $Session -Recurse
Copy-Item $SwimRepoPath -Destination $DispatcherDeployBackupPath -force -ToSession $Session -Recurse
Copy-Item $JTRepoPath -Destination $DispatcherDeployBackupPath -force -ToSession $Session -Recurse
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
}else{
write-host "No Modification to Dispatcher Server files, skip copying repo files to server !!"
}
