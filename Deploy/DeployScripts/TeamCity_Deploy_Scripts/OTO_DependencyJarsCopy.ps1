Param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$ServerPath= $HomePath +"tcroot\illumina\BulkItemCreation\DependencyJars",
[String]$RepoCopyFilesPath= $RepoPath + "\SourceCode\Customization\DependencyJars\*",
[String]$GitFileChangePath="SourceCode/Configuration/OTO/",
[String]$GitMasterChangeFilePath=$RepoPath +"\Deploy\DeployScripts\Git_Compare\MasterGitDelta.txt"
)
$Found=Get-Content $GitMasterChangeFilePath | Where-Object {$_ -match $GitFileChangePath}
write-host "Found: " $Found
if ($Found){
write-host "OTO: Copy DependencyJars !!"
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
}-ArgumentList $ServerPath
# Above ends Remote Session.
Copy-Item $RepoCopyFilesPath -Destination $ServerPath -force -ToSession $Session -Recurse
Remove-PSSession -Session $Session
}
}else{
write-host "Skip OTO: Copying DependencyJars !!"
}
