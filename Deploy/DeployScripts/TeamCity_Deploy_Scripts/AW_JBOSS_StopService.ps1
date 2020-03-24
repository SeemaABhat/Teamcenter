param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[String]$ServiceFuctionPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Services.ps1",
[String]$ServiceName= "Teamcenter_12_Wildfly*"
)
Write-Host "JBOSS \ Wildfly ServiceName: " $ServiceName
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
$process = "java.exe"
Get-WmiObject Win32_Process -Filter "name = '$process'" | where {$_.CommandLine -like '*D:\Apps\wildfly-15.*'}| 
foreach { 
$_.terminate()
Write-host "Java process with command line killed !!"
}
} 
. $ServiceFuctionPath
Write-host "Validate if Teamcenter_12_Wildfly is stopped"
$Error_Level = Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopService} `
-ArgumentList $ServiceName
Write-Host "Error_Level: " $Error_Level
if($Error_Level -eq 1){
	exit 1
}
Remove-PSSession -Session $Session
}
