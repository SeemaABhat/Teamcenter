param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$ServiceFuctionPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Services.ps1",
[String]$DispatcherClientServiceName= "Teamcenter DispatcherClient*",
[String]$ModuleServiceName= "Teamcenter Dispatcher Module*",
[String]$SchedulerServiceName= "Teamcenter Dispatcher Scheduler*"
)
Write-Host "Dispatcher Client ServiceName: " $DispatcherClientServiceName
Write-Host "Module Service Name: " $ModuleServiceName
Write-Host "Scheduler Service Name: " $SchedulerServiceName
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
. $ServiceFuctionPath
# Invoke Remote Session.
$Error_Level1=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StartService} `
-ArgumentList $SchedulerServiceName
Write-Host "Scheduler Service Name: " $SchedulerServiceName " Error_Level1: " $Error_Level1
$Error_Level2=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StartService} `
-ArgumentList $ModuleServiceName
Write-Host "Module Service Name: " $ModuleServiceName " Error_Level2: " $Error_Level2
$Error_Level3=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StartService} `
-ArgumentList $DispatcherClientServiceName
Write-Host "Dispatcher Client Service Name: " $DispatcherClientServiceName " Error_Level3: " $Error_Level3
if(($Error_Level1 -eq 1) -or ($Error_Level2 -eq 1) -or ($Error_Level3 -eq 1)){
	exit 1
}
Remove-PSSession -Session $Session
}
