Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$serverPath= $HomePath + "tcroot\include",
[String]$ExternalLibRepoPath= $RepoPath + "\SourceCode\Configuration\BMIDE\ExternalLibs\RapidJSON\include\*"
)
write-host "serverPath: " $serverPath
write-host "ExternalLibRepoPath: " $ExternalLibRepoPath
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
Copy-Item $ExternalLibRepoPath -Destination $serverPath -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}
