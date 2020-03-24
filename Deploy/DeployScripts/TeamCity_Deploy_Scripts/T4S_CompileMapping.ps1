Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$batServerFilePath= $HomePath+"T4S_build_mapping.bat",
[String]$LogFilePath= $HomePath+"Log_T4Sbuildmapping.txt",
[String]$ErrorFilePath= $HomePath+"ErrorLog_T4Sbuildmapping.txt",
[String]$batFilePath=$RepoPath+"\SourceCode\Configuration\TeamCity\T4S_build_mapping.bat",
[String]$GitFileChangePath="SourceCode/Integration/T4S/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt",
[String]$EmptyString="Empty"
)
write-host "RepoPath: " $RepoPath
write-host "Username: " $Username
write-host "Password: " $Password
write-host "HostName: " $HostName
write-host "HomePath: " $HomePath
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "T4S files are modified, Compile files !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Copy-Item $batFilePath -Destination $HomePath -force -ToSession $Session -Recurse
$Status=Invoke-Command -Session $Session -ScriptBlock {
Invoke-Expression "$args[0] $args[1], $args[2], $args[3], $args[4]" > $args[2] 2> $args[3]
$ErrorFound=Get-Content $args[3] | Where-Object {$_ -match "RROR:"}
write-host "ErrorFound: " $ErrorFound
if( $LASTEXITCODE -eq 0 -and [string]::IsNullOrEmpty($ErrorFound)) {
	$returncode="Success"
	write-host "Compiling T4S attribute maps Success !!"
} else {
	$returncode="Failed"
	write-host "Compiling T4S attribute maps Failed"
}
$returncode
}-ArgumentList $batServerFilePath, $HomePath, $LogFilePath, $ErrorFilePath, $EmptyString
Invoke-Command -Session $Session -ScriptBlock {
Get-Content $args[0]
}-ArgumentList $LogFilePath
# Above ends Remote Session.
if($Status -eq "Failed"){
	exit 1
}
Remove-PSSession -Session $Session
}
}else{
write-host "No modification to T4S files, skip compiling files !!"
}
