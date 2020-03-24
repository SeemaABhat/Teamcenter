Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$PropertyFilePath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$SwimEnvSpecPath= $RepoPath + $PropertyFilePath+"\*",
[String]$GitFileChangePath="SourceCode/Configuration/SWIM/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$SwimFilePath= $RepoPath+"\SourceCode\Configuration\SWIM\*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Swim files are modified, deploy swim files !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Above ends Remote Session.
Copy-Item -Path (Get-Item -Path $SwimFilePath -Exclude ('ClientSwim12.1')).FullName -Destination $HomePath -force -ToSession $Session -Recurse
Copy-Item $SwimEnvSpecPath -Destination $HomePath -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}
}else{
write-host "No Modification to swim files, skip deploying swim files !!"
}
