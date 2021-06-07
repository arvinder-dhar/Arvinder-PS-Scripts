##Author : Arvinder Dhar
##Task: To Retreive uptime and last patched report for all Trusted Domain Joined servers
## HTML Editor Reference URL : https://www.w3schools.com/html/

######START######

[array]$Trusted_Domains = (Get-ADTrust -Filter * | Where-Object {$_.name -like "*something*" -or $_.name -like "*something*"}).name

foreach ($Trust in $Trusted_Domains) {

try{
[array]$servers += (Get-ADComputer -Filter { Name -like "*" } -Properties * -Server $Trust | Where-Object { $_.DNSHostname -notlike "*some-Server*" }).DNSHostname | select -Unique
[array]$active_domain += $Trust

}

catch { #do nothing
}
}

 foreach($server in $servers){

 $remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $server -Count 2 -Quiet

 if ($remote -eq "True" -and $ping -eq "True"){

 try{
  
       #Creating a Table

       $ServerDetails = "" | Select ServerName,IP,OS,Last_Reboot_Date,Uptime_in_days,Last_Patched_Date,Patchtime_in_days

       $Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $server -ErrorAction SilentlyContinue
       $date_conversion = $Boot.ConvertToDateTime($Boot.LastBootUpTime)
       $startdate = $date_conversion.ToString("MMM-dd-yyyy hh:mm:ss tt")

       $EndDate =  Get-Date
       $uptime = (New-TimeSpan -Start $startdate -End $EndDate).days
     
       $patchedon = (Get-WmiObject -Class win32_quickfixengineering -ComputerName $server -ErrorAction SilentlyContinue | sort InstalledOn -Descending | select -First 1).InstalledOn
       $patchdate = $patchedon.ToString("MMM-dd-yyyy hh:mm:ss tt")
   
       $patch_days =  (New-TimeSpan -Start $patchdate -End $EndDate).days

       $ServerDetails.ServerName = $Server
       $ServerDetails.IP = ((Test-Connection $server -count 1).IPV4Address).IPAddressToString
       $ServerDetails.OS = (Get-WmiObject -Class win32_operatingsystem -ComputerName $server | select -Property *).caption
       $ServerDetails.Last_Reboot_Date = $startdate
       $serverDetails.Uptime_in_days = $uptime
       $ServerDetails.Last_Patched_Date = $patchdate
       $ServerDetails.Patchtime_in_days = $patch_days

       $ServerDetails
       [array]$Report_ServerDetails += $ServerDetails

       [array]$sucess_data += $ServerDetails
       $sucesscount = $sucess_data.count
   
       }
       
Catch{

      $ServerDetails = "" | Select ServerName,IP,OS,Last_Reboot_Date,Uptime_in_days,Last_Patched_Date,Patchtime_in_days

      $ServerDetails.ServerName = $Server 
      $ServerDetails.IP = ((Test-Connection $server -count 1).IPV4Address).IPAddressToString
      $ServerDetails.OS = "Server Up, however no info fetched"
      $ServerDetails.Last_Reboot_Date = "NA"
      $ServerDetails.Uptime_in_days = "NA"
      $ServerDetails.Last_Patched_Date = "NA"
      $ServerDetails.Patchtime_in_days = "NA"
    
      $ServerDetails
      [array]$Report_ServerDetails += $ServerDetails
      
      [array]$partial_sucess_data += $ServerDetails
      $partialsucesscount = $partial_sucess_data.count
     }

    }

else {

      $ServerDetails = "" | Select ServerName,IP,OS,Last_Reboot_Date,Uptime_in_days,Last_Patched_Date,Patchtime_in_days

      $ServerDetails.ServerName = $Server 
      $ServerDetails.IP = "Server not Reachable"
      $ServerDetails.OS = "NA"
      $ServerDetails.Last_Reboot_Date = "NA"
      $ServerDetails.Uptime_in_days = "NA"
      $ServerDetails.Last_Patched_Date = "NA"
      $ServerDetails.Patchtime_in_days = "NA" 
  
      $ServerDetails
      [array]$Report_ServerDetails += $ServerDetails

      [array]$fail_data += $ServerDetails
      $failcount = $fail_data.count
           
    }
}

$Report_ServerDetails

$currentdate = (Get-Date).ToShortDateString()
$worksheet = $currentdate.Replace("/","-")

$Report_ServerDetails | Export-Excel "\\DFS_Path\Uptime-Report-$currentdate.xlsx".Replace("/","-") -AutoSize -WorkSheetname "Uptime-Report-$worksheet" -FreezeTopRow -BoldTopRow -AutoFilter

$attachment = @("\DFS_Path\Uptime-Report-$currentdate.xlsx".Replace("/","-"))
$smtp = "SMTP-Server"

$Subject = "Uptime-Report"
$Body_part = Get-Date -Format "MMM-dd-yyyy"

##Body Table Data Collection

$servercount = $servers.count
$domaincount = $active_domain.count

$Body = "<font size='+1.2'>Uptime Report for <b>all Trusted Domain Joined</b> servers is attached for <b><font color=black>$Body_part </b></font> <br>
</font>
<font size='+1.2'>Report has been fetched from <b>Server: <u>Server-Name</u></b> <br></font>
<html>
<head>
<style>
table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
}

tr:nth-child(even) {
  background-color: #dddddd;
}
</style>
</head>
<body>

<h3>Below is the Report Analysis in Tabular Form</h3>

<table>
  <tr>
    <th>Total Servers</th>
    <th>Total Active Domains</th>
    <th>Servers with Successful Data Extraction</th>
    <th>Servers Currently Down</th>
    <th>Servers Up but Failed Data Extraction</th>
  </tr>
  <tr>
    <td>$servercount</td>
    <td>$domaincount</td>
    <td>$sucesscount</td>
    <td>$failcount</td>
    <td>$partialsucesscount</td>
  </tr>
</table>

</body>
</html> "

$From = "Sender-Address"
$To = "Recepient Adress"
$cc = "CC Address"

Send-MailMessage -From $From -To $To -cc $cc -Attachments $attachment -SmtpServer $smtp -Subject $Subject -Body $Body -BodyAsHtml

######END######