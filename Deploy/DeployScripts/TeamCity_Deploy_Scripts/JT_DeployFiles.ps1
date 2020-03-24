Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$GitFileChangePath="SourceCode/Configuration/JTTranslators/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$JTPackageFilePath= $RepoPath+"\SourceCode\Configuration\JTTranslators\SolidWorks_V18\*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "JTTranslators files are modified, deploy JTTranslators files!!"
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Above ends Remote Session.
Copy-Item $JTPackageFilePath -Destination $HomePath -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}
}else{
write-host "No Modification to JTTranslators files, skip deployment of JTTranslators !!"
}
