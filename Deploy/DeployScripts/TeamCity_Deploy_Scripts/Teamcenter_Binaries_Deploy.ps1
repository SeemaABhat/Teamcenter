Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$PropertyFilePath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$EnvSpecPath= $RepoPath + $PropertyFilePath+"\*",
[String]$BinariesPath= $RepoPath + "\SourceCode\Configuration\Binaries\*",
[String]$GitFileChangePath="SourceCode/Configuration/Binaries/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt"
)
write-host "GitMasterChangeFilePath: " $GitMasterChangeFilePath
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Binaries are modified !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
Copy-Item $EnvSpecPath -Destination $HomePath -force -ToSession $Session -Recurse
Copy-Item $BinariesPath -Destination $HomePath -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}
}else{
write-host "No Modifications to Binaries !!"
}
