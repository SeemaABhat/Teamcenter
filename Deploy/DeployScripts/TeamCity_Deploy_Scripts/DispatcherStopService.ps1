param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$ServiceFuctionPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Services.ps1",
[String]$ServiceDispatcherClientPath= $HomePath+"DispatcherClient*",
[String]$ServiceModulePath= $HomePath+"Module*",
[String]$ServiceSchedulerPath= $HomePath+"Scheduler*"
)
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
. $ServiceFuctionPath
# Invoke Remote Session.
Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopProcess} `
-ArgumentList $ServiceDispatcherClientPath, "Teamcenter DispatcherClient"
Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopProcess} `
-ArgumentList $ServiceModulePath, "Teamcenter Dispatcher Module"
Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopProcess} `
-ArgumentList $ServiceSchedulerPath, "Teamcenter Dispatcher Schedule"
Write-host "Validate if Dispatcher services are stopped !!"
$Error_Level1=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopService} `
-ArgumentList "Teamcenter DispatcherClient*"
Write-Host "Teamcenter DispatcherClient Error_Level1: " $Error_Level
$Error_Level2=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopService} `
-ArgumentList "Teamcenter Dispatcher Module*"
Write-Host "Teamcenter Dispatcher Module Error_Level2: " $Error_Level2
$Error_Level3=Invoke-Command -Session $Session ` -ScriptBlock ${Function:StopService} `
-ArgumentList "Teamcenter Dispatcher Schedule*"
Write-Host "Teamcenter Dispatcher Schedule Error_Level3: " $Error_Level3
if( ($Error_Level1 -eq 1) -or ($Error_Level2 -eq 1) -or ($Error_Level3 -eq 1)){
	exit 1
}
Remove-PSSession -Session $Session
}
