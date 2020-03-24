Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$SyslogPath= "C:\BuildAgent\Illumina\BMIDE\package",
[String]$BMIDEProject= $RepoPath+"\SourceCode\Configuration\BMIDE",
[String]$LogFilePath= "C:\BuildAgent\Illumina\BMIDE\package\Log_BMIDE_CreatePackage.txt",
[String]$ErrorFilePath= "C:\BuildAgent\Illumina\BMIDE\package\ErrorLog_BMIDE_CreatePackage.txt",
[String]$batFilePath= $RepoPath+"\SourceCode\Configuration\TeamCity\BMIDE_CreatePackage.bat",
[String]$EmptyString="Empty"
)
$Status= Invoke-Command -ScriptBlock {
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4], $args[5], $args[6]" > $args[2] 2> $args[3]
$ErrorFound=Get-Content $args[3] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "BMIDE Package created Successfully !!"
} else {
	$returncode="Failed"
	write-host "BMIDE Package creation Failed"
}
$returncode
}-ArgumentList $batFilePath, $HomePath, $LogFilePath, $ErrorFilePath, $SyslogPath, $BMIDEProject, $EmptyString
Invoke-Command -ScriptBlock {
Get-Content $args[0]
Get-Content $args[1]
}-ArgumentList $LogFilePath, $ErrorFilePath
if($Status -eq "Failed"){
	exit 1
}
