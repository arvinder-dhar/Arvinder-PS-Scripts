#Author : Arvinder
#Description : Script will get the .Net version for servers in servers.txt file
#Limitations : Need to manually check .Net version based on Release number, based on below ref
# Will edit script at alater stage to include these changes

<#
	30319  = 4.0                                                     
        378389 = 4.5                                                     
        378675 = 4.5.1        
        378758 = 4.5.1       
        379893 = 4.5.2                                                   
        380042 = 4.5
        393295 = 4.6   
        393297 = 4.6
        394254 = 4.6.1  
        394271 = 4.6.1    
        394802 = 4.6.2
        394806 = 4.6.2     
        460798 = 4.7      
        460805 = 4.7         
        461308 = 4.7.1
        461310 = 4.7.1    
        461808 = 4.7.2            
        461814 = 4.7.2

        #>

$servers = $null
$ServerDetails = $null
$final_report = $null

$servers = Get-Content .\servers.txt

 foreach($server in $servers){

 $remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $server -Quiet

 if ($remote -eq "True" -and $ping -eq "True"){

 try{
  
       #Creating a Table
       $version = $null
       $release = $null

       $ServerDetails = "" | Select ServerName,Version,Release
       $ServerDetails.ServerName = $server

       $version = Invoke-Command -ComputerName $server -ScriptBlock { (Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').GetValue("Version") }
       $ServerDetails.Version = $version

       $release = Invoke-Command -ComputerName $server -ScriptBlock { (Get-Childitem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').GetValue("Release") }
       $ServerDetails.Release = $release
   
       $ServerDetails
       [array]$final_report += $ServerDetails
   
       }
       
Catch{

      $ServerDetails = "" | Select ServerName,Version,Release

      $ServerDetails.ServerName = $Server 
      $ServerDetails.Version = "Server Up, however no info fetched"
      $ServerDetails.Release = "NA"
         
      $ServerDetails
      [array]$final_report += $ServerDetails
     }

    }

else {

      $ServerDetails = "" | Select ServerName,Version,Release

      $ServerDetails.ServerName = $Server 
      $ServerDetails.Version = "Server not reachable"
      $ServerDetails.Release = "NA" 
  
      $ServerDetails
      [array]$final_report += $ServerDetails
      
    }
}

$final_report

$final_report | Export-Excel suw_dot_net.xlsx -AutoSize