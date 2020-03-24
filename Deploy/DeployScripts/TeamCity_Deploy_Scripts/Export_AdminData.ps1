Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$InfodbaPWD,
[Parameter(Mandatory=$false)] [String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$ServerBackupPath,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$GitFileChangePath="SourceCode/Configuration/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$OutputFolderPackage= $ServerBackupPath +"\AdminDataExport_" + $CurrentDate + "_" + $BuildNumber,
[String]$BatFilePath= $DeployBackupPath +"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\TeamCity\Export_Admin_Data.bat",
[String]$OutputPackage= $ServerBackupPath +"\AdminDataExport_" + $CurrentDate + "_" + $BuildNumber+"\AdminDataExport.zip",
[String]$LogFilePath= $ServerBackupPath +"\AdminDataExport_" + $CurrentDate + "_" + $BuildNumber+"\Log_AdminDataExport.txt",
[String]$ErrorFilePath= $ServerBackupPath +"\AdminDataExport_" + $CurrentDate + "_" + $BuildNumber+"\ErrorLog_AdminDataExport.txt",
[String]$TC_ROOT=$HomePath + "tcroot",
[String]$EmptyString="Empty"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "Teamcenter Configuration are modified, take admin data export !!"
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

write-host "HomePath: " $HomePath
write-host "TC_ROOT: " $TC_ROOT
write-host "BatFilePath: " $BatFilePath
write-host "OutputPackage: " $OutputPackage

$Status=Invoke-Command -Session $Session -ScriptBlock {
If(!(test-path -Path $args[6]))
{
    New-Item -ItemType Directory -Path $args[6]
}
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7]" > $args[4] 2> $args[5]
$ErrorFound=Get-Content $args[5] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "Admin Data Exported Successfully !!"
} else {
	$returncode="Failed"
	write-host "Admin Data Export Failed"
}
$returncode
}-ArgumentList $BatFilePath, $HomePath, $InfodbaPWD, $OutputPackage, $LogFilePath, $ErrorFilePath, $OutputFolderPackage, $EmptyString
Invoke-Command -Session $Session -ScriptBlock {
Get-Content $args[0]
Get-Content $args[1]
}-ArgumentList $LogFilePath, $ErrorFilePath
# Above ends Remote Session.
if($Status -eq "Failed"){
	exit 1
}
Remove-PSSession -Session $Session
}else{
write-host "No modification to Teamcenter Configuration, skip taking admin data export !!"
}
