## Author : Arvinder
## Description : Will get all patches for servers retreived from servers.txt file
## Note : Don't export report using export-csv use only export-excel

$servers = $null
$final_report = $null
$ServerDetails = $null

$servers = Get-Content .\servers.txt

 foreach($server in $servers){

 $remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $server -Quiet

 if ($remote -eq "True" -and $ping -eq "True"){

 try{

       #Creating a Table

       $Hotfix = $null
       $ServerDetails = "" | Select ServerName,Ping_Status,Hotfix_Id

       $ServerDetails.ServerName = $server
       $ServerDetails.Ping_Status = "Server is Up"

       $Hotfix += (Get-HotFix -ComputerName $server).HotFixID -join "," | Out-String
       $ServerDetails.Hotfix_Id += $Hotfix

       $ServerDetails
       [array]$final_report += $ServerDetails
   
       }
       
Catch{

       $ServerDetails = "" | Select ServerName,Ping_Status,Hotfix_Id

       $ServerDetails.ServerName = $server
       $ServerDetails.Ping_Status = "Server Up, however no info fetched"
       $ServerDetails.Hotfix_Id = "NA"

       $ServerDetails
       [array]$final_report += $ServerDetails
     }

    }

else {

       $ServerDetails = "" | Select ServerName,Ping_Status,Hotfix_Id

       $ServerDetails.ServerName = $server
       $ServerDetails.Ping_Status = "Server not Reachable"
       $ServerDetails.Hotfix_Id = "NA"

       $ServerDetails
       [array]$final_report += $ServerDetails
      
    }
}

$final_report | Export-Excel report.xlsx -AutoSize