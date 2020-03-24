Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$JBossHomePathWeb,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$WarFilePath= $RepoPath+"\SourceCode\Customization\AW\awc.war",
[String]$GitFileChangePath="SourceCode/Customization/AW/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt"
)
write-host "JBossHomePathWeb: " $JBossHomePathWeb

$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "AW files are modified, copy awc.war to Web Server !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

Copy-Item $WarFilePath -Destination $JBossHomePathWeb -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}
}else{
write-host "No Modifications to AW, skip copying awc.war to Web Server !!"
}
