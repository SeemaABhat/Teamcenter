Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$PropertyFilePath,
[Parameter(Mandatory=$false)] [String]$DMPropertyFilePath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$GitFileChangePath="SourceCode/Customization/Dispatcher/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$DispatcherFilePath= $RepoPath+"\SourceCode\Configuration\Dispatcher_Root\*",
[String]$DisMonitorFilePath= $RepoPath+"\SourceCode\Configuration\DispatcherMonitor\*",
[String]$DispatcherEnvSpecPath= $RepoPath + $PropertyFilePath+"\*",
[String]$DisMonitorEnvSpecPath= $RepoPath + $DMPropertyFilePath+"\*"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Dispatcher files are modified, deploy Dispatcher files !!"
Write-Host "Pool Manager ServiceName: " $PoolManagerServiceName
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$DisMonitorHomePath = Split-Path -Path $HomePath -Parent
$DisMonitorHomePath = $DisMonitorHomePath +"\DispatcherMonitor"
write-host "DisMonitorHomePath: " $DisMonitorHomePath
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
    If(!(test-path -Path $args[0]))
{
    New-Item -ItemType Directory -Path $args[0]
}
}-ArgumentList $DisMonitorHomePath
Copy-Item $DispatcherFilePath -Destination $HomePath -force -ToSession $Session -Recurse
Copy-Item $DispatcherEnvSpecPath -Destination $HomePath -force -ToSession $Session -Recurse
Copy-Item $DisMonitorFilePath -Destination $DisMonitorHomePath -force -ToSession $Session -Recurse
Copy-Item $DisMonitorEnvSpecPath -Destination $DisMonitorHomePath -force -ToSession $Session -Recurse
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
}else{
write-host "No Modification to Dispatcher files, skip deploying Dispatcher files !!"
}
