Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$InfodbaPWD,
[Parameter(Mandatory=$false)] [String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[Parameter(Mandatory=$false)] [String]$OTO,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$LogFilePath= $DeployBackupPath +"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\BMIDE\Log_BMIDE.txt",
[String]$ErrorFilePath= $DeployBackupPath +"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\BMIDE\ErrorLog_BMIDE.txt",
[String]$BMIDETemplatePath= $DeployBackupPath +"\TCConfiguration_" + $CurrentDate + "_" + $BuildNumber+"\BMIDE\output\wntx64\packaging\full_update\il9base_wntx64",
[String]$TC_ROOT=$HomePath + "tcroot",
[String]$Syslog=$HomePath + "tcroot\logs",
[String]$GitFileChangePath="SourceCode/Configuration/BMIDE/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$templateName="il9base"
)
write-host "GitMasterChangeFilePath: " $GitMasterChangeFilePath
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "BMIDE files are modified !!"
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

write-host "BMIDETemplatePath: " $BMIDETemplatePath
write-host "HomePath: " $HomePath
write-host "TC_ROOT: " $TC_ROOT
write-host "templateName: " $templateName
write-host "OTO: " $OTO

$escapeparser= '--%'
if ($OTO -eq "True"){
$Command="$TC_ROOT\install\tem.bat -install -features=$templateName -path=$BMIDETemplatePath -pass=$InfodbaPWD"
write-host "One Time Only "
}else{
$Command="$TC_ROOT\install\tem.bat -update -templates=$templateName -path=$BMIDETemplatePath -full -pass=$InfodbaPWD"
write-host "BMIDE Update"
}

write-host "Command: " $Command
write-host "Syslog Path : " $Syslog
$Status=Invoke-Command -Session $Session -ScriptBlock {
$out=Invoke-Expression $args[0] > $args[1] 2> $args[2]
write-host "Executing Command : " $args[0]
$ErrorFound=Get-Content $args[2] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "BMIDE Imported Successfully !!"
} else {
	$returncode="Failed"
	write-host "BMIDE import Failed"
}
$returncode
}-ArgumentList $Command, $LogFilePath, $ErrorFilePath
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
write-host "No Modifications to BMIDE !!"
}
