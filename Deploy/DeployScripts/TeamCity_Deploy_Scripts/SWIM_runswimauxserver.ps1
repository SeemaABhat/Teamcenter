Param(
[Parameter(Mandatory=$false)] [String]$Username,
[Parameter(Mandatory=$false)] [String]$Password,
[Parameter(Mandatory=$false)] [String]$HostName,
[Parameter(Mandatory=$false)] [String]$HomePath,
[String]$CurrentDate= (Get-Date -Format "dd-MM-yyyy"),
[String]$BATFilePath= $HomePath +"runswimauxserver.bat"
)
# Remote Server.
$pw = convertto-securestring -AsPlainText -Force -String $Password
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
$Session = New-PSSession -ComputerName $HostName -Credential $cred
# Above ends Remote Session.
Invoke-Command -Session $Session -ScriptBlock {
$process = "java.exe"
Get-WmiObject Win32_Process -Filter "name = '$process'" | where {$_.CommandLine -like '*com.transcendata.swimsoaaux.SwimAux*'}| 
foreach { 
$_.terminate()
Write-host "Java process with command line killed !!"
}
}
Remove-PSSession -Session $Session
Invoke-Command -ComputerName $HostName -ScriptBlock {
$CompName=$args[1]
$command=$args[0]
$process = [WMICLASS]"\\$CompName\ROOT\CIMV2:win32_process"
$result = $process.Create($command)
write-host "restarted runAuxSwim"
}-ArgumentList $batFilePath, $HostName  -Credential $cred -ErrorAction Stop
