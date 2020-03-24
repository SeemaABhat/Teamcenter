Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname
)
write-host " Kill TC Process !!"
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
$SearchProcess = "*\Siemens\*"
get-process | where-object {$_.path -like $SearchProcess} | where-object {!($_.ProcessName -like "*TcFSC*")} | Stop-process -force

$SearchProcess = "*\Teamcenter12\*"
get-process | where-object {$_.path -like $SearchProcess} | where-object {!($_.ProcessName -like "*TcFSC*")} | Stop-process -force
}
write-host " Completed killing TC Process !!"
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
