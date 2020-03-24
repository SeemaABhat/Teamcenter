Workflow backupServerFiles([string]$MultipleHostname, [string]$Username, [string]$Password, [string]$SourcePath, [string]$DestinationPath, [string]$DFSPath, [string]$DFSServer, [string]$envName)
{
$MultipleHostnameList = $MultipleHostname.split(",");
$DFSServerList = $DFSServer.split(",");
ForEach -Parallel ($Hostname in $MultipleHostnameList ) {
   inlinescript{
        $Hostname=$Using:Hostname
        $Password=$Using:Password
        $Username=$Using:Username
        $SourcePath=$Using:SourcePath
        $DestinationPath=$Using:DestinationPath
        $VolumePath=$DestinationPath+"\volume"
        $DFSServerList=$Using:DFSServerList
        $DFSPath=$Using:DFSPath
        $DFSSourcePath=$DFSPath+"\*"
        $envName=$Using:envName

        write-host "Hostname: " $Hostname

        $pw = convertto-securestring -AsPlainText -Force -String $Password
        $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $Username,$pw
        $Session = New-PSSession -ComputerName $Hostname -Credential $cred
        
        # Invoke Remote Session.
        Invoke-Command -Session $Session -ScriptBlock {
        If(!(test-path -Path $args[1])){
            New-Item -ItemType Directory -Path $args[1]
            }
        
        if($args[5] -contains $args[8]){
            If(!(test-path -Path $args[2])){
                New-Item -ItemType Directory -Path $args[2]
            }
            Copy-Item -Path (Get-Item -Path $args[0] -Exclude ('volume')).FullName  -recurse -Destination $args[1] -force
            $userNameDFS=$args[6]
            net use  $args[3] /user:$userNameDFS $args[7]
            Copy-Item -Path $args[4] -Destination $args[2] -force -recurse
          }else{
            Copy-Item -Path $args[0] -Destination $args[1] -force -recurse
            }

        }-ArgumentList $SourcePath, $DestinationPath, $VolumePath, $DFSPath ,$DFSSourcePath, $DFSServerList, $Username, $Password, $envName
        Remove-PSSession -Session $Session
      }
    }
 }
