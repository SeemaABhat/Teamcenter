Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$InfodbaPWD,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$repoBatfolderPath= $RepoPath +"\SourceCode\Configuration\TeamCity\ClearLocks.bat",
[String]$batfolderPath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber,
[String]$LogFilePath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber+"\Log_ClearLocks.txt",
[String]$ErrorFilePath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber+"\ErrorLog_ClearLocks.txt",
[String]$batFilePath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber+"\ClearLocks.bat",
[String]$EmptyString="Empty"
)
write-host "Clear Locks !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

Invoke-Command -Session $Session -ScriptBlock {
If(!(test-path -Path $args[0]))
{
    New-Item -ItemType Directory -Path $args[0]
}
}-ArgumentList $batfolderPath
Copy-Item $repoBatfolderPath -Destination $batfolderPath -force -ToSession $Session

$Status= Invoke-Command -Session $Session -ScriptBlock {
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4], $args[5]" > $args[3] 2> $args[4]
$ErrorFound=Get-Content $args[4] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "Complete Clearing Locks !!"
} else {
	$returncode="Failed"
	write-host "Failed Clearing Locks"
}
$returncode
}-ArgumentList $batFilePath, $HomePath, $InfodbaPWD, $LogFilePath, $ErrorFilePath, $EmptyString
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
