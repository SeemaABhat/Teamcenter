Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$MultipleHostname
)
write-host " Disconnect all open Files !!"
Write-Host "Pool Manager ServiceName: " $PoolManagerServiceName
$MultipleHostnameList = $MultipleHostname.split(",");
ForEach ($HostName in $MultipleHostnameList ) {
Write-Host "HostName: " $HostName
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Invoke Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
$cmd = "OPENFILES /Disconnect /O Read/Write"
Invoke-Expression $cmd
Get-SmbSession
Get-SmbSession | ForEach-Object {Close-SmbSession -Force}
Get-SmbSession
}
write-host " Completed disconnecting all open Files !!"
# Above ends Remote Session.
Remove-PSSession -Session $Session
}
