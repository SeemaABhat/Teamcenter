Function EnableTask([string]$TaskName){
$Error_Level=0
try{
    $taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName }
    If ($taskExists) {
	    if (Get-ScheduledTask $TaskName | Where-Object {$_.State -eq "Disabled"} ){
            Write-Host "Task " $TaskName "is in disable state, enabling !!"
            Enable-ScheduledTask -TaskName $TaskName
            Write-Host "Task " $TaskName "enabled !!"
        }elseif(Get-ScheduledTask $TaskName | Where-Object {($_.State -eq "Ready") -or ($_.State -eq "Running")}){
            Write-Host "Task "$TaskName "already enabled !!! "
        }else{
            $task = Get-ScheduledTask $TaskName
            $taskState = $task.State
	        Write-Host "Error: Task "$TaskName "- State: " $taskState
            $Error_Level=1
        }
    }else{
            Write-Host "Error: Task "$TaskName " not found !!"
            $Error_Level=1
    }
}catch{
    Write-Host "Problem occured while disabling task "$TaskName
    Write-Host "Exception details: " $PSItem.Exception.Message
    $Error_Level=1
}
return $Error_Level
}
Function DisableTask([string]$TaskName){
$Error_Level=0
try{
    $taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $TaskName }
    If ($taskExists) {
	    if (Get-ScheduledTask $TaskName | Where-Object {($_.State -eq "Ready") -or ($_.State -eq "Running")} ){
            Write-Host "Task " $TaskName "is in ready state, disabling !!"
            Disable-ScheduledTask -TaskName $TaskName
            Write-Host "Task " $TaskName "disabled !!"
        }elseif(Get-ScheduledTask $TaskName | Where-Object {$_.State -eq "Disabled"}){
            Write-Host "Task "$TaskName "already disabled !!! "
        }else{
            $task = Get-ScheduledTask $TaskName
            $taskState = $task.State
	        Write-Host "Error: Task "$TaskName "- State: " $taskState
            $Error_Level=1
        }
    }else{
            Write-Host "Error: Task "$TaskName " not found !!"
            $Error_Level=1
    }
}catch{
    Write-Host "Problem occured while disabling task "$TaskName
    Write-Host "Exception details: " $PSItem.Exception.Message
    $Error_Level=1
}
return $Error_Level
}
Function StopProcess([string]$ProcessPath, [string]$ServiceName){
$Error_Level=0
write-host "Process Path: " $ProcessPath
write-host "Service Name: " $ServiceName
Try{
	get-process | where-object {$_.path -like $ProcessPath} | Stop-process -force -processname {$_.processname}
	Write-host "Service " $ServiceName " Stopped !!"
}catch{
	Write-host "Problem occurred while stopping Service: " $ServiceName
	$Error_Level=1
}
return $Error_Level
}
Function StopService([string]$ServiceDisplayName){
$Error_Level=0
try{
    If (Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName }) {
	    if ((Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName }).Status -eq "Running"){
		    Write-Host "Service " $ServiceDisplayName "is running, preparing to stop !!"
		    Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName } | where-object {!$_.startuptype -eq "Disabled" } | Stop-Service -Force
            Start-Sleep -Seconds 5
            Write-Host "Service " $ServiceDisplayName "Stopped !!"
	    }elseif ((Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName }).Status -eq "Stopped"){
		    Write-Host "Service "$ServiceDisplayName "already stopped !!! "
	    }else{
		Write-Host "Error: Service "$ServiceDisplayName "-" $ServiceStatus "!!"
        	$Error_Level=1
	    }
    }else{
	    Write-Host "Error: Service "$ServiceDisplayName " not found !!"
	    $Error_Level=1
    }
}catch{
    Write-Host "Problem occured while stopping service "$ServiceDisplayName
    Write-Host "Exception details: " $PSItem.Exception.Message
    $Error_Level=1
}
return $Error_Level
}

Function StartService([string]$ServiceDisplayName){
$Error_Level=0
try{
    If (Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName }) {
	    if ((Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName }).Status -eq "Running"){
		    Write-Host $ServiceDisplayName "already running!"
	    }elseif ((Get-Service -Name $ServiceDisplayName).Status -eq 'Stopped'){
		    Write-Host $ServiceName "is stopped, preparing to start..."
		    Get-Service | where-object {$_.DisplayName -like $ServiceDisplayName } | where-object {!$_.startuptype -eq "Disabled" } | Start-Service
            Start-Sleep -Seconds 5
            Write-Host "Service " $ServiceDisplayName "Started !!"
	    }else{
		Write-Host "Error: Service "$ServiceDisplayName "-" $ServiceStatus
            	$Error_Level=1
	    }
    }else{
	    Write-Host "Error: Service "$ServiceDisplayName " not found !!"
	    $Error_Level=1
    }
}catch{
    Write-Host "Problem occured while Starting service "$ServiceDisplayName
    Write-Host "Exception details: " $PSItem.Exception.Message
    $Error_Level=1
}
return $Error_Level
}
