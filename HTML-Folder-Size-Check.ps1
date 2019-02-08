##Author : Arvinder Dhar
##Task: To Retreive Particular folder size for all Trusted Domain Joined servers
## HTML Editor Reference URL : https://www.w3schools.com/html/

######START######

$servers = $null
$Report_ServerDetails = $null
$Trusted_Domains = $null
$1gb_greater = $null
$1gb_lesser = $null

[array]$Trusted_Domains = (Get-ADTrust -Filter * | Where-Object {$_.name -like "*something*" -or $_.name -like "*something*"}).name

foreach ($Trust in $Trusted_Domains)

{
try{

[array]$servers += (Get-ADComputer -Filter { Name -like "*" } -Properties * -Server $Trust | Where-Object { $_.DNSHostname -notlike "d*" }).DNSHostname | select -Unique
}

catch { #Do nothing 
Write-Warning "$Trust Domain is not reachable"
}
}

foreach($server in $servers){

 $remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
 $ping = Test-Connection -ComputerName $server -Count 2 -Quiet

 if ($remote -eq "True" -and $ping -eq "True"){

  
       #Creating a Table

       $ServerDetails = "" | Select ServerName,Folder_in_MB,Folder_in_GB
       $ServerDetails.ServerName = $Server

       $Folder_Mb = [math]::round((Invoke-Command -ComputerName $server -ScriptBlock { (Get-ChildItem -Path "Folder Path" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).sum/1Mb }),2)
       $Folder_Gb = [math]::round((Invoke-Command -ComputerName $server -ScriptBlock { (Get-ChildItem -Path "Folder Path" -Recurse | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).sum/1Gb }),2)

       $ServerDetails.Folder_in_MB =  $Folder_Mb
       $ServerDetails.Folder_in_GB = $Folder_Gb

       if ($Folder_Mb -like "0" ) {
       
       $ServerDetails.Folder_in_MB =  "Folder Either Empty or not found"
       $ServerDetails.Folder_in_GB =  "NA"
       
       }

       if ($Folder_Gb -gt "1") {

       [array]$1gb_greater += $ServerDetails
       $1gb_greater_count = $1gb_greater.count

       }

       else {

       [array]$1gb_lesser += $ServerDetails
       $1gb_lesser_count = $1gb_lesser.count

       }
       $ServerDetails
      [array]$Report_ServerDetails += $ServerDetails
              
    }

else {

      $ServerDetails = "" | Select ServerName,Folder_in_MB,Folder_in_GB
      $ServerDetails.ServerName = $Server
  
      $ServerDetails.Folder_in_MB =  "Server not reachable"
      $ServerDetails.Folder_in_GB = "NA"
       
      $ServerDetails
      [array]$Report_ServerDetails += $ServerDetails

      [array]$fail_data += $ServerDetails
      $failcount = $fail_data.count
      
    }
}

$Report_ServerDetails

$currentdate = (Get-Date).ToShortDateString().Replace("/","-")

$Report_ServerDetails | Export-Excel "\\DFS_Path\Folder-Size-Report-$currentdate.xlsx" -AutoSize -WorkSheetname "Folder-size-Report-$currentdate" -FreezeTopRow -BoldTopRow -AutoFilter

$attachment = @("\\DFS_Path\Folder-Size-Report-$currentdate.xlsx".Replace("/","-"))
$smtp = "SMTP-Server-Name"
$Subject = "Folder-Size-Report"

$Body_part = Get-Date -Format "MMM-dd-yyyy"
$servercount = $servers.count

$Body = "<font size='+1.2'>Folder Size Report for <b>all Trusted Domain Joined</b> servers is attached for <b><font color=black>$Body_part </b></font> <br>
</font>
<font size='+1.2'>Report has been fetched from <b>server: <u>Server-Name</u></b> <br></font>
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
    <th>Servers More than 1GB Folder size</th>
    <th>Servers Less than 1GB Folder size</th>
    <th>Servers Down or Failed Data Extraction</th>
     </tr>
  <tr>
    <td>$servercount</td>
    <td>$1gb_greater_count</td>
    <td>$1gb_lesser_count</td>
    <td>$failcount</td>
    </tr>
</table>

</body>
</html>"

$From = "Sender-Address"
$To = "Recepient Adress"
$cc = "CC Address"

Send-MailMessage -From $From -To $To -cc $cc -Attachments $attachment -SmtpServer $smtp -Subject $Subject -Body $Body -BodyAsHtml

######END######