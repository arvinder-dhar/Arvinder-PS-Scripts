# AUthor : Arvinder
# Description : Script will find out servers that have uptime of more than 90 Days

$servers = $null
$Report_ServerDetails = $null
 
$servers = Get-Content C:\Servers.txt
 
foreach($server in $servers){
 
$remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $server -Quiet
 
if ($remote -eq "True" -and $ping -eq "True"){
 
try{
 
       #Creating a Table
 
       $ServerDetails = "" | Select ComputerName,Uptime,OS
       $ServerDetails.ComputerName = $Server
 
       $Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $server -ErrorAction SilentlyContinue
 
       $startdate = $Boot.ConvertToDateTime($Boot.LastBootUpTime)
 
       $EndDate =  Get-Date
       $uptime = (New-TimeSpan -Start $startdate -End $EndDate).days
 
       $os = (Get-WmiObject -ComputerName $server -Class win32_operatingsystem).caption
      
       $serverDetails.Uptime = $uptime
       $ServerDetails.OS = $os
 
       if ( $uptime -ge 90)
 
       {
 
       $ServerDetails
       [array]$Report_ServerDetails += $ServerDetails
 
       }
 
      
       
      
       }
      
Catch{
 
      $ServerDetails = "" | Select ComputerName,Uptime,OS
      $ServerDetails.ComputerName = $Server
      $ServerDetails.Uptime = "Information cannot be fetched"
     
      $os = (Get-WmiObject -ComputerName $server -Class win32_operatingsystem).caption
 
      $ServerDetails.OS = $os
   
      [array]$Failed += $ServerDetails
      $ServerDetails
}
    }
 
else {
 
      $ServerDetails = "" | Select ComputerName,Uptime,OS
      $ServerDetails.ComputerName = $Server
      $ServerDetails.Uptime = "Server is not reachable"
 
      $ServerDetails.OS = "NA"
     
      [array]$Failed += $ServerDetails 
      $ServerDetails
     
    }
}
 
$Report_ServerDetails | Export-Excel Uptime_MoreThan_90Days.xlsx
$Failed | Export-Excel Failed_to_Retreive.xlsx