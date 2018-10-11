##Author : Arvinder Dhar
##Task: To Retreive uptime report for all Domain Controllers and Certain Terminal Servers in all Trusted domains
##Version : 3
 
##Additional tasks : Gets last patch date and calculates the days too for all DCs and Terminal servers
##Improvements : Works on PS Version 2.0
 
[array]$Trusted_Domains = (Get-ADTrust -Filter *).name
$servers = $null
$Report_ServerDetails = $null
 
foreach ($Trust in $Trusted_Domains)
 
{
try{
[array]$servers += (Get-ADDomainController -Filter * -Server $Trust).Hostname
[array]$servers += (Get-ADComputer -Filter 'Name -like "Terminal_Server_nominclature"' -Server $Trust).DNSHostName # For Terminal Servers
}
 
catch { Write-Warning "$Trust Domain is not reachable"}
}
 
foreach($server in $servers){
 
$remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $server -Quiet
 
if ($remote -eq "True" -and $ping -eq "True"){
 
try{
 
       #Creating a Table
 
       $ServerDetails = "" | Select ComputerName,Uptime,PatchDate,PatchDays
       $ServerDetails.ComputerName = $Server
      
       $Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $server -ErrorAction SilentlyContinue
       $startdate = $Boot.ConvertToDateTime($Boot.LastBootUpTime)
 
       $patchdate = (Get-WmiObject -Class win32_quickfixengineering -ComputerName $server -ErrorAction SilentlyContinue | sort InstalledOn -Descending | select -First 1).InstalledOn
       $EndDate =  Get-Date
       $uptime = (New-TimeSpan -Start $startdate -End $EndDate).days
       $serverDetails.Uptime = $uptime
 
       $patch_days =  (New-TimeSpan -Start $patchdate -End $EndDate).days
 
       $ServerDetails.PatchDate = $patchdate
       $ServerDetails.PatchDays = $patch_days
     
       [array]$Report_ServerDetails += $ServerDetails
       $ServerDetails
      
       }
      
Catch{
 
      $ServerDetails = "" | Select ComputerName,Uptime,PatchDate,PatchDays
      $ServerDetails.ComputerName = $Server
      $ServerDetails.Uptime = "Information cannot be fetched"
      $ServerDetails.PatchDate = "NA"
      $ServerDetails.PatchDays = "NA"
      [array]$Report_ServerDetails += $ServerDetails
      $ServerDetails
}
    }
 
else {
 
      $ServerDetails = "" | Select ComputerName,Uptime,PatchDate,PatchDays
      $ServerDetails.ComputerName = $Server
      $ServerDetails.Uptime = "Server is not reachable"
      $ServerDetails.PatchDate = "NA"
      $ServerDetails.PatchDays = "NA"
      [array]$Report_ServerDetails += $ServerDetails  
      $ServerDetails
     
    }
}
 
$Report_ServerDetails
$Report_ServerDetails | Export-Csv Trusted_Domain_DC_Terminal_Server_uptime.csv -NoTypeInformation
