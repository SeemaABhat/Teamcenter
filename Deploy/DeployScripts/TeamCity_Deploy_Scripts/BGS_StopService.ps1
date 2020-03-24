param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[String]$ServiceFuctionPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Services.ps1",
[String]$GSServiceName= "Teamcenter*_GS"
)
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
. $ServiceFuctionPath
# Invoke Remote Session.
$Error_Level = Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopService} `
-ArgumentList $GSServiceName
if( $Error_Level -eq 1){
	exit 1
}
Remove-PSSession -Session $Session
}
