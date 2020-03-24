param(
[Parameter(Mandatory=$false)] [String]$RepoPath,
[Parameter(Mandatory=$false)] [String]$CorpUsername,
[Parameter(Mandatory=$false)] [String]$CorpPassword,
[Parameter(Mandatory=$false)] [String]$CorpHostName,
[Parameter(Mandatory=$false)] [String]$DispatcherUsername,
[Parameter(Mandatory=$false)] [String]$DispatcherPassword,
[Parameter(Mandatory=$false)] [String]$DispatcherHostName,
[String]$corpTaskName="BulkItemCreation",
[String]$DispatcherTaskName="DispatcherTaskMonitor",
[String]$ServiceFuctionPath= $RepoPath+"\Deploy\DeployScripts\TeamCity_Deploy_Scripts\Services.ps1"
)

$pw = convertto-securestring -AsPlainText -Force -String $CorpPassword
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $CorpUsername,$pw
$CorpSession = New-PSSession -ComputerName $CorpHostName -Credential $cred
. $ServiceFuctionPath
# Invoke Remote Session.
Invoke-Command -Session $CorpSession ` -ScriptBlock ${Function:DisableTask} `
-ArgumentList $corpTaskName
Remove-PSSession -Session $CorpSession

$pw1 = convertto-securestring -AsPlainText -Force -String $DispatcherPassword
$cred1 = new-object -typename System.Management.Automation.PSCredential -argumentlist $DispatcherUsername,$pw1
$DispatcherCorpSession = New-PSSession -ComputerName $DispatcherHostName -Credential $cred1
. $ServiceFuctionPath
# Invoke Remote Session.
Invoke-Command -Session $DispatcherCorpSession ` -ScriptBlock ${Function:DisableTask} `
-ArgumentList $DispatcherTaskName
Remove-PSSession -Session $DispatcherCorpSession
