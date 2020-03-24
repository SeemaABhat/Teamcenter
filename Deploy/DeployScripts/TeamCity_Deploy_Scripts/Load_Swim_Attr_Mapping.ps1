Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$InfodbaPWD,
[Parameter(Mandatory=$false)] [String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[Parameter(Mandatory=$false)][String]$Tcdata,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$SyslogPath= $DeployBackupPath+"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\swim_Attr_Mapping",
[String]$LogFilePath= $DeployBackupPath+"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\swim_Attr_Mapping\Log_swim_Attr_Mapping.txt",
[String]$ErrorFilePath= $DeployBackupPath+"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\swim_Attr_Mapping\ErrorLog_swim_Attr_Mapping.txt",
[String]$FilePath= $DeployBackupPath+"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\swim_Attr_Mapping\swim_attr_mappings.txt",
[String]$BATFilePath= $DeployBackupPath+"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\swim_Attr_Mapping\Import_SwimAttrMapping.bat",
[String]$GitFileChangePath="SourceCode/Configuration/swim_Attr_Mapping/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$EmptyString="Empty"
)
write-host "GitMasterChangeFilePath: " $GitMasterChangeFilePath
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "swim_Attr_Mapping files are modified !!"
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

$Status= Invoke-Command -Session $Session -ScriptBlock {
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7]" > $args[4] 2> $args[5]
$ErrorFound=Get-Content $args[5] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "swim_Attr_Mapping Imported Successfully !!"
} else {
	$returncode="Failed"
	write-host "swim_Attr_Mapping import Failed"
}
$returncode
}-ArgumentList $BATFilePath, $HomePath, $InfodbaPWD, $FilePath, $LogFilePath, $ErrorFilePath, $SyslogPath, $EmptyString
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
write-host "No Modifications to swim_Attr_Mapping !!"
}
