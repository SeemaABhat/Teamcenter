Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$BuildAgentHomePath,
[String]$BMIDEPackage= $RepoPath+"\SourceCode\Configuration\BMIDE\output\wntx64\packaging\full_update\il9base_wntx64\artifacts",
[String]$zipFolder=$BMIDEPackage+"\il9base_template.zip",
[String]$BMIDEPackageFilesToModel=$BMIDEPackage+"\install\il9base\*",
[String]$modelServerPath= $HomePath+"tcdata\model\*",
[String]$SyslogPath="C:\BuildAgent\Illumina\BMIDE\compare",
[String]$modelBuildAgentPath= "C:\BuildAgent\Illumina\BMIDE\compare\model",
[String]$clearFilePath= "C:\BuildAgent\Illumina\BMIDE\compare",
[String]$LogFilePath= "C:\BuildAgent\Illumina\BMIDE\compare\Log_BMIDE_Delta_Compare.txt",
[String]$ErrorFilePath= "C:\BuildAgent\Illumina\BMIDE\compare\ErrorLog_BMIDE_Delta_Compare.txt",
[String]$batFilePath= $RepoPath+"\SourceCode\Configuration\TeamCity\BMIDE_Delta_Compare.bat",
[String]$EmptyString="Empty"
)
If(!(test-path -Path $modelBuildAgentPath))
{
    write-host "Create model folder !!"
    New-Item -ItemType Directory -Path $modelBuildAgentPath
} else {
    write-host "Delete old model folder & create new one !!"
    Remove-Item -LiteralPath $clearFilePath -Force -Recurse
    New-Item -ItemType Directory -Path $modelBuildAgentPath
}
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Copy-Item $modelServerPath -Destination $modelBuildAgentPath -force -FromSession $Session -Recurse
Remove-PSSession -Session $Session

Expand-Archive -LiteralPath $zipFolder -DestinationPath $BMIDEPackage
Copy-Item $BMIDEPackageFilesToModel -Destination $modelBuildAgentPath -force -Recurse
$Status= Invoke-Command -ScriptBlock {
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4], $args[5], $args[6], $args[7], $args[8]" > $args[2] 2> $args[3]
$ErrorFound=Get-Content $args[3] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "BMIDE delta created Successfully !!"
	write-host "Delta File Creation here: C:\BuildAgent\Illumina\BMIDE\compare\Delta.xml"
} else {
	$returncode="Failed"
	write-host "BMIDE delta creation Failed"
}
$returncode
}-ArgumentList $batFilePath, $BuildAgentHomePath, $LogFilePath, $ErrorFilePath, $SyslogPath, $EmptyString
Invoke-Command -ScriptBlock {
write-host "!! START of Logs !! "
Get-Content $args[0]
Get-Content $args[1]
write-host "!! END of Logs !! "
}-ArgumentList $LogFilePath, $ErrorFilePath
if($Status -eq "Failed"){
	exit 1
}
