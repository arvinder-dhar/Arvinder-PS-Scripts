##Author : Arvinder Dhar
##Version : 4
##Task: Generates uptime report for DC's, Terminal Servers, Certificate servers and DFS Servers in given Domain

##Additional tasks : Included certificate servers and DFS Servers as well, 
                    # Excel file will be generated and saved automatically to current users desktop
                    # Certain servers that are not requied but have similarity in prefix will be removed automatically

##Improvements : Works on PS Version 2.0 as well

$servers = $null
$Report_ServerDetails = $null

[array]$servers = (Get-ADDomainController -Filter 'Name -notlike "Certain_Server*"').name
[array]$servers += (Get-ADComputer -Filter 'Name -like "*Terminal_Servers*"' -Properties * | Where-Object {$_.Name -notlike "Certain_Server*"}).name
[array]$servers += (Get-ADComputer -Filter 'Name -like "*DFS_Servers*"' -Properties * | Where-Object {$_.Name -notlike "Certain_Server*"}).name
[array]$servers += (Get-ADComputer -Filter 'Name -like "*Certificate_Servers*"' -Properties * | Where-Object {$_.Name -notlike "Certain_Server*"}).name

 foreach($server in $servers){

 $remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $server -Quiet

 if ($remote -eq "True" -and $ping -eq "True"){

 try{
  
       #Creating a Table to Create server name and the uptime

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
$Report_ServerDetails | Export-Excel C:\Users\$env:USERNAME\Desktop\Domain_Name_DC_Terminal_CS_DFS_uptime.xlsx -AutoSize