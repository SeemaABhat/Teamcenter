Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$DispatcherTcrootPath,
[Parameter(Mandatory=$false)] [String]$TeamCentertcdata,
[Parameter(Mandatory=$false)] [String]$TeamCenterUsername,
[Parameter(Mandatory=$false)] [String]$TeamCenterPassword,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)][String]$DeployBackupPath,
[Parameter(Mandatory=$false)][String]$ServerName,
[Parameter(Mandatory=$false)][String]$dcproxypwd,
[Parameter(Mandatory=$false)][String]$SameEnvTCdata,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$LogFilePath= $DeployBackupPath+"\OTO_" + $CurrentDate + "_" + $BuildNumber+"\TeamCity\Log_DispatcherPwd.txt",
[String]$ErrorFilePath= $DeployBackupPath+"\OTO_" + $CurrentDate + "_" + $BuildNumber+"\TeamCity\ErrorLog_DispatcherPwd.txt",
[String]$GitFileChangePath="SourceCode/Configuration/OTO/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$BATFilePath= $DeployBackupPath+"\OTO_" + $CurrentDate + "_" + $BuildNumber+"\TeamCity\DispatcherPwd_Creation.bat"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "OTO: create dcproxxy password file !!"
$SameEnvTCdataList = $SameEnvTCdata.split(",");
if($SameEnvTCdataList -match $ServerName){
	$networktcdata="nonnetworktcdata"
}else{
	$networktcdata="networktcdata"
}
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Above ends Remote Session.
$Status= Invoke-Command -Session $Session -ScriptBlock {
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8], $args[9]" > $args[7] 2> $args[8]
$ErrorFound=Get-Content $args[8] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "Password File created Successfully !!"
} else {
	$returncode="Failed"
	write-host "Password File creation Failed"
}
$returncode
}-ArgumentList $BATFilePath, $DispatcherTcrootPath, $TeamCentertcdata, $TeamCenterUsername, $TeamCenterPassword, $dcproxypwd, $networktcdata, $LogFilePath, $ErrorFilePath, $EmptyString
Invoke-Command -Session $Session -ScriptBlock {
Get-Content $args[0]
Get-Content $args[1]
}-ArgumentList $LogFilePath, $ErrorFilePath
# Above ends Remote Session.
if($Status -eq "Failed"){
	exit 1
}
Remove-PSSession -Session $Session
}
}else{
write-host "Skip OTO: create dcproxxy password file !!"
}
