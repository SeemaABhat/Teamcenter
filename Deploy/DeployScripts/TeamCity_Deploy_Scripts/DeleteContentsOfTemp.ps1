Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)][String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$repoBatfolderPath= $RepoPath +"\SourceCode\Configuration\TeamCity\DeleteContentsTemp.bat",
[String]$batfolderPath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber,
[String]$LogFilePath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber+"\Log_DeleteContentsOfTemp.txt",
[String]$ErrorFilePath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber+"\ErrorLog_DeleteContentsOfTemp.txt",
[String]$batFilePath= $DeployBackupPath +"\StopServices_" + $CurrentDate + "_" + $BuildNumber+"\DeleteContentsTemp.bat",
[String]$EmptyString="Empty"
)
write-host "Delete Contents Of Temp !!"
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
# Remote Server.
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
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4]" > $args[2] 2> $args[3]
$ErrorFound=Get-Content $args[3] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "Complete deleting Contents Of Temp !!"
} else {
	$returncode="Failed"
	write-host "Failed deleting Contents Of Temp"
}
$returncode
}-ArgumentList $batFilePath, $HomePath, $LogFilePath, $ErrorFilePath, $EmptyString
Invoke-Command -Session $Session -ScriptBlock {
Get-Content $args[0]
}-ArgumentList $LogFilePath
# Above ends Remote Session.
if($Status -eq "Failed"){
	exit 1
}
Remove-PSSession -Session $Session
}
