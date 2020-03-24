Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$BuildNumber,
[Parameter(Mandatory=$false)] [String]$DeployBackupPath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$Command1=$HomePath+"initenv.cmd",
[String]$Command2=$HomePath+"gwtcompile.cmd",
[String]$LogFolderPath= $DeployBackupPath +"\AW_" + $CurrentDate + "_" + $BuildNumber,
[String]$WarFileRepoPath= $RepoPath+"\SourceCode\Customization\AW\awc.war",
[String]$WarFileSourcePath= $HomePath+"out\awc.war",
[String]$LoginitenvFilePath= $DeployBackupPath +"\AW_" + $CurrentDate + "_" + $BuildNumber+"\Log_AWinitenv.txt",
[String]$ErrorinitenvFilePath= $DeployBackupPath +"\AW_" + $CurrentDate + "_" + $BuildNumber+"\ErrorLog_AWinitenv.txt",
[String]$LoggwtcompileFilePath= $DeployBackupPath +"\AW_" + $CurrentDate + "_" + $BuildNumber+"\Log_AWgwtcompile.txt",
[String]$ErrorgwtcompileFilePath= $DeployBackupPath +"\AW_" + $CurrentDate + "_" + $BuildNumber+"\ErrorLog_AWgwtcompile.txt",
[String]$GitFileChangePath="SourceCode/Customization/AW/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "AW files are modified, create War File !!"
$initenvCommand="$Command1"
$gwtcompileCommand="$Command2"
write-host "initenvCommand: " $initenvCommand
write-host "gwtcompileCommand: " $gwtcompileCommand
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred

Invoke-Command -Session $Session -ScriptBlock {
If(!(test-path -Path $args[0]))
{
    New-Item -ItemType Directory -Path $args[0]
}
}-ArgumentList $LogFolderPath
$Status1=Invoke-Command -Session $Session -ScriptBlock {
Invoke-Expression $args[0] > $args[1] 2> $args[2]
write-host "Executing Command : " $args[0]
$ErrorFound=Get-Content $args[2] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode1="Success"
	write-host "initenv.cmd executed Successfully !!"
} else {
	$returncode1="Failed"
	write-host "initenv.cmd execution Failed"
}
$returncode1
}-ArgumentList $Command1, $LoginitenvFilePath, $ErrorinitenvFilePath
Invoke-Command -Session $Session -ScriptBlock {
Get-Content $args[0]
Get-Content $args[1]
}-ArgumentList $LoginitenvFilePath, $ErrorinitenvFilePath
$Status2=Invoke-Command -Session $Session -ScriptBlock {
Invoke-Expression $args[0] > $args[1] 2> $args[2]
write-host "Executing Command : " $args[0]
$ErrorFound=Get-Content $args[2] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode2="Success"
	write-host "gwtcompile.cmd executed Successfully !!"
} else {
	$returncode2="Failed"
	write-host "gwtcompile.cmd execution Failed"
}
$returncode2
}-ArgumentList $Command2, $LoggwtcompileFilePath, $ErrorgwtcompileFilePath
Invoke-Command -Session $Session -ScriptBlock {
Get-Content $args[0]
Get-Content $args[1]
}-ArgumentList $LoggwtcompileFilePath, $ErrorgwtcompileFilePath
if($Status1 -eq "Failed" -Or $Status2 -eq "Failed"){
	exit 1
}else{
Copy-Item $WarFileSourcePath -Destination $WarFileRepoPath -force -FromSession $Session -Recurse
write-host "awc.war file moved to Repo Path !!"
}
Remove-PSSession -Session $Session
}else{
write-host "No Modifications to AW, skip creating war file !!"
}
