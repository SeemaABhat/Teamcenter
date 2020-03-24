param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[String]$ServiceFuctionPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Services.ps1",
[String]$PoolManagerServiceName= "Teamcenter Server Manager*"
)
Write-Host "Pool Manager ServiceName: " $PoolManagerServiceName
Write-Host "MultipleHostname: " $MultipleHostname
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
. $ServiceFuctionPath
# Invoke Remote Session.
$Error_Level=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopService} `
-ArgumentList $PoolManagerServiceName
Write-Host "Error_Level: " $Error_Level
if($Error_Level -eq 1){
	exit 1
}
Remove-PSSession -Session $Session
}
