Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[Parameter(Mandatory=$false)] [String]$PropertyFilePath,
[String]$RenamemmapPathFrom= $HomePath + "var\mmap",
[String]$RenamemmapPathTo= $HomePath + "var\mmap_OOTB",
[String]$DeployFilesRepoPath=$RepoPath+"\SourceCode\Integration\T4S\gs\*",
[String]$DeployEnvFilesRepoPath=$RepoPath + $PropertyFilePath+"\gs\*",
[String]$GitFileChangePath="SourceCode/Integration/T4S/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "T4S files are modified, deploy files !!"
# Remote Server.
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
    If(!(test-path -Path $args[1]))
{
    Rename-Item $args[0] $args[1]
    New-Item -ItemType Directory -Path $args[0]
}
}-ArgumentList $RenamemmapPathFrom, $RenamemmapPathTo
Copy-Item $DeployFilesRepoPath -Destination $HomePath -force -ToSession $Session -Recurse
Copy-Item $DeployEnvFilesRepoPath -Destination $HomePath -force -ToSession $Session -Recurse
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
}else{
write-host "No modification to T4S files, skip deploying files !!"
}
