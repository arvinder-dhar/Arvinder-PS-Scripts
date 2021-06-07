##Author : Arvinder
##Description : Script will generate the report that will have the servername and the status for AV agent/services fetched from servers.txt file
##Run_Instructions : Make sure only NetBIOS name is present in the servers.txt file
##Output will be saved in AV_Status.xlsx file

$servers = $null
$service_name = $null
$ServerDetails = $null
$final_report = @()

$servers = Get-Content C:\Users\$env:USERNAME\Desktop\servers.txt

foreach($server in $servers){

if ($server -like "abc*" -or $Server -like "xyz*") { # Check certain servers that need to excluded, Such servers have common Prefixes

$remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $server -Quiet

 if ($remote -eq "True" -and $ping -eq $true) {

       try {

       $ServerDetails = "" | Select-Object ComputerName,Access_Status,Agent_Status,Service_Status
       $ServerDetails.ComputerName = $Server
       $ServerDetails.Access_Status = "Reachable"

       $agent_installed = [bool](Invoke-Command -ComputerName $server -ScriptBlock `
       {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.displayname -like "AVAgent*"}})
       
       if ($agent_installed -eq $true) {
       $ServerDetails.Agent_Status = "Installed"
       $service = [bool](Get-Service -ComputerName $server | Where-Object {$_.displayname -like "AVAgent*" -and $_.Status -eq "Stopped" })

       if ($service -eq $true)
       {
       $service_name = ((Get-Service -ComputerName $server | Where-Object {$_.displayname -like "AVAgent*" -and $_.Status -eq "Stopped" })).Name
       $ServerDetails.Service_Status = "$service_name is not running"
       }

       else {$ServerDetails.Service_Status = "All AVAgent services are running"}
       }

       else {
       $ServerDetails.Agent_Status = "Not Installed"
       $ServerDetails.Service_Status ="NA"

        }
  
       [array]$final_report += $ServerDetails  
       $ServerDetails 
       
       }
       
       catch {
       
      $ServerDetails = "" | Select-Object ComputerName,Access_Status,Agent_Status,Service_Status
      $ServerDetails.ComputerName = $Server 
      $ServerDetails.Access_Status = "Not reachable"
      $ServerDetails.Agent_Status = "NA"
      $ServerDetails.Service_Status = "NA"
      [array]$final_report += $ServerDetails
      $ServerDetails  
       
       } 

    }

else {

      $ServerDetails = "" | Select-Object ComputerName,Access_Status,Agent_Status,Service_Status
      $ServerDetails.ComputerName = $Server 
      $ServerDetails.Access_Status = "Not reachable"
      $ServerDetails.Agent_Status = "NA"
      $ServerDetails.Service_Status = "NA"
      [array]$final_report += $ServerDetails
      $ServerDetails  
      
    }
}

else {

$fqdn = $server + "." + $server.SubString(0,5) + ".remaining_FQDN_Part" # this is in case NETBIOS Name is given and server if from another Trusted Domain

 $remote= [bool](Test-WSMan -ComputerName $fqdn -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $fqdn -Quiet

 if ($remote -eq "True" -and $ping -eq $true) {

       try {

       $ServerDetails = "" | Select-Object ComputerName,Access_Status,Agent_Status,Service_Status
       $ServerDetails.ComputerName = $fqdn
       $ServerDetails.Access_Status = "Reachable"

       $agent_installed = [bool](Invoke-Command -ComputerName $fqdn -ScriptBlock `
       {Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.displayname -like "AVAgent*"}})
       
       if ($agent_installed -eq $true) {
       $ServerDetails.Agent_Status = "Installed"
       $service = [bool](Get-Service -ComputerName $fqdn | Where-Object {$_.displayname -like "AVAgent*" -and $_.Status -eq "Stopped" })

       if ($service -eq $true)
       {
       $service_name = ((Get-Service -ComputerName $fqdn | Where-Object {$_.displayname -like "AVAgent*" -and $_.Status -eq "Stopped" })).Name
       $ServerDetails.Service_Status = "$service_name is not running"
       }

       else {$ServerDetails.Service_Status = "All AVAgent services are running"}
       }

       else {
       $ServerDetails.Agent_Status = "Not Installed"
       $ServerDetails.Service_Status ="NA"

        }
  
       [array]$final_report += $ServerDetails  
       $ServerDetails
       }
       
       catch {
       
      $ServerDetails = "" | Select-Object ComputerName,Access_Status,Agent_Status,Service_Status
      $ServerDetails.ComputerName = $fqdn 
      $ServerDetails.Access_Status = "Not reachable"
      $ServerDetails.Agent_Status = "NA"
      $ServerDetails.Service_Status = "NA"
      [array]$final_report += $ServerDetails
      $ServerDetails  
       
       }   

    }

else {

      $ServerDetails = "" | Select-Object ComputerName,Access_Status,Agent_Status,Service_Status
      $ServerDetails.ComputerName = $fqdn 
      $ServerDetails.Access_Status = "Not reachable"
      $ServerDetails.Agent_Status = "NA"
      $ServerDetails.Service_Status = "NA"
      [array]$final_report += $ServerDetails
      $ServerDetails  
      
    }

    }
}

$final_report
$final_report | Export-Excel C:\Users\$env:USERNAME\Desktop\AV_Status.xlsx -AutoSize