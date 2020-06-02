######Start######

<# Author: Arvinder
  Short Description : Script will retreive uptime and patch reports for all domains and will send that info via e-mail
  Domains : 
        1. Domain1
        2. Domain2
        3. Domain3
        4. Domain4
        5. Domain5
        6. Domain6

  HTML Editor Reference URL's : 
    1. https://www.w3schools.com/html/  
    2. https://www.tablesgenerator.com/html_tables
    3. https://adamtheautomator.com/powershell-convertto-html/ (To be explored more)

  Next Version : Consolidate all Reports in one workbook
#>         

Function Get-ADDCUptimePatchReport {
  [CmdletBinding()]
  Param(
      #Want to support multiple computers
      [Parameter(Mandatory=$true,
                  ValueFromPipeline=$true,
                  ValueFromPipelineByPropertyName=$true)]
      [String]$Domain
  )

Begin{}
Process{
$servers = $null

[array]$servers = (Get-ADDomainController -Filter 'name -like "*"' -Server $Domain).hostname

foreach($server in $servers){

$remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $server -Count 2 -Quiet

if ($remote -eq "True" -and $ping -eq "True"){

try{

$IP = ((Test-Connection $server -count 1).IPV4Address).IPAddressToString
$OS = (Get-WmiObject -Class win32_operatingsystem -ComputerName $server | Select-Object -Property *).caption
$Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $server -ErrorAction SilentlyContinue
$date_conversion = $Boot.ConvertToDateTime($Boot.LastBootUpTime)
$startdate = $date_conversion.ToString("MMM-dd-yyyy hh:mm:ss tt")
$EndDate =  Get-Date
$uptime = (New-TimeSpan -Start $startdate -End $EndDate).days

$patchedon = (Get-WmiObject -Class win32_quickfixengineering -ComputerName $server -ErrorAction SilentlyContinue | Sort-Object InstalledOn -Descending | Select-Object -First 1).InstalledOn
$patchdate = $patchedon.ToString("MMM-dd-yyyy")
 
$patch_days =  (New-TimeSpan -Start $patchdate -End $EndDate).days

$property = [ordered] @{
'Domain Controller' = $server ;
'IP' = $IP ;
'OS' = $OS ;
'Rebooted On' = $startdate ;
'Uptime (Days)' = $uptime ;
'Patched On' = $patchdate ;
'Patch Duration (Days)' = $patch_days ;
 }

}
     
Catch{

$property = [ordered] @{
'Domain Controller' = $server ;
'IP' = $IP ;
'OS' = "Server Up, however no info fetched" ;
'Rebooted On' = "NA" ;
'Uptime (Days)' = "NA" ;
'Patched On' = "NA" ;
'Patch Duration (Days)' = "NA" ;
 }
     
}

}

else {

$property = [ordered] @{
  'Domain Controller' = $server ;
  'IP' = "Server not Reachable" ;
  'OS' = "NA" ;
  'Rebooted On' = "NA" ;
  'Uptime (Days)' = "NA" ;
  'Patched On' = "NA" ;
  'Patch Duration (Days)' = "NA" ;
   }
         
  }

$Object = New-Object -TypeName PSObject -Property $property
Write-Output $Object

}

}

End {}

}

$start_time = get-date -Format "MMM-dd-yyyy hh:mm:ss tt"
$currentdate = (Get-Date).ToShortDateString()

$domain1_data = Get-ADDCUptimePatchReport -Domain "Domain1"
$domain2_data = Get-ADDCUptimePatchReport -Domain "Domain2" 
$domain3_data = Get-ADDCUptimePatchReport -Domain "Domain3"
$domain4_data = Get-ADDCUptimePatchReport -Domain "Domain4"
$domain5_data = Get-ADDCUptimePatchReport -Domain "Domain5"
$domain6_data = Get-ADDCUptimePatchReport -Domain "Domain6"

$From = "Reports@xyz.com"
$To = "abc@xyz.com"
$cc = "abc@xyz.com"

$domain1_data | Export-Csv "D:\Reports\domain1-Uptime-Patch-Report-$currentdate.csv".Replace("/","-") -NoTypeInformation
$domain2_data | Export-Csv "D:\Reports\domain2-Uptime-Patch-Report-$currentdate.csv".Replace("/","-") -NoTypeInformation
$domain3_data | Export-Csv "D:\Reports\domain3-Uptime-Patch-Report-$currentdate.csv".Replace("/","-") -NoTypeInformation
$domain4_data | Export-Csv "D:\Reports\domain4-Uptime-Patch-Report-$currentdate.csv".Replace("/","-") -NoTypeInformation
$domain5_data | Export-Csv "D:\Reports\domain5-Uptime-Patch-Report-$currentdate.csv".Replace("/","-") -NoTypeInformation
$domain6_data | Export-Csv "D:\Reports\domain6-Uptime-Patch-Report-$currentdate.csv".Replace("/","-") -NoTypeInformation

$csv_extension = Get-Date -Format MM-d
Get-ChildItem | Where-Object {$_.Name -like "*$csv_extension*"} | Select-Object -ExpandProperty FullName | Import-Csv | Export-Csv "D:\Reports" -NoTypeInformation -Append

$attachment = @("D:\Reports\domain1-Uptime-Patch-Report-$currentdate.csv".Replace("/","-"),"D:\Reports\domain2-Uptime-Patch-Report-$currentdate.csv".Replace("/","-"),"D:\Reports\domain3-Uptime-Patch-Report-$currentdate.csv".Replace("/","-"),"D:\Reports\domain4-Uptime-Patch-Report-$currentdate.csv".Replace("/","-"),"D:\Reports\domain5-Uptime-Patch-Report-$currentdate.csv".Replace("/","-"),"D:\Reports\domain6-Uptime-Patch-Report-$currentdate.csv".Replace("/","-"))

$Body_part = Get-Date -Format "MMM-dd-yyyy"
$Subject = "Uptime-Patch-Report-All-Domains-$Body_part"
$smtp = "smtp.xyz.com"

##Body Table Data Collection

$domain1_count = $domain1_data."domain controller".count
$domain1_partial_success = ($domain1_data | Where-Object {$_.OS -like "*no info*"}  | Measure-Object).count
$domain1_failed = ($domain1_data | Where-Object {$_.IP -like "*not Reach*"} | Measure-Object).count
$domain1_success = $domain1_count - ($domain1_partial_success + $domain1_failed)

$domain2_count = $domain2_data."domain controller".count
$domain2_partial_success = ($domain2_data | Where-Object {$_.OS -like "*no info*"} | Measure-Object).count
$domain2_failed = ($domain2_data | Where-Object {$_.IP -like "*not Reach*"} | Measure-Object).count
$domain2_success = $domain2_count - ($domain2_partial_success + $domain2_failed)
   
$domain3_count = $domain3_data."domain controller".count
$domain3_partial_success = ($domain3_data | Where-Object {$_.OS -like "*no info*"} | Measure-Object).count
$domain3_failed = ($domain3_data | Where-Object {$_.IP -like "*not Reach*"} | Measure-Object).count
$domain3_success = ($domain3_count - ($domain3_partial_success + $domain3_failed))

$domain4_count = $domain4_data."domain controller".count
$domain4_partial_success = ($domain4_data | Where-Object {$_.OS -like "*no info*"} | Measure-Object).count
$domain4_failed = ($domain4_data | Where-Object {$_.IP -like "*not Reach*"} | Measure-Object).count
$domain4_success = $domain4_count - ($domain4_partial_success + $domain4_failed)

$domain5_count = $domain5_data."domain controller".count
$domain5_partial_success = ($domain5_data | Where-Object {$_.OS -like "*no info*"} | Measure-Object).count
$domain5_failed = ($domain5_data | Where-Object {$_.IP -like "*not Reach*"} | Measure-Object).count
$domain5_success = $domain5_count - ($domain5_partial_success + $domain5_failed)

$domain6_count = $domain6_data."domain controller".count
$domain6_partial_success = ($domain6_data | Where-Object {$_.OS -like "*no info*"} | Measure-Object).count
$domain6_failed = ($domain6_data | Where-Object {$_.IP -like "*not Reach*"} | Measure-Object).count
$domain6_success = $domain6_count - ($domain6_partial_success + $domain6_failed)

$end_time = get-date -Format "MMM-dd-yyyy hh:mm:ss tt"

$Body = "<font size='+1.2'>Uptime and Patch Reports for all<b> 6 Domain DCs</b> are attached for<b><font color=black> $Body_part</b><br>
<br>

<style type=text/css >
.tg  {border-collapse:collapse;border-spacing:0;border-color:#9ABAD9;}
.tg td{font-family:Arial sans-serif;font-size:14px;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#9ABAD9;color:#444;background-color:#EBF5FF;}
.tg th{font-family:Arial sans-serif;font-size:14px;font-weight:normal;padding:10px 5px;border-style:solid;border-width:1px;overflow:hidden;word-break:normal;border-color:#9ABAD9;color:#fff;background-color:#409cff;}
.tg .tg-8ot9{font-size:15px;border-color:inherit;text-align:center;vertical-align:top}
.tg .tg-u5pr{font-weight:bold;font-size:15px;font-family:Arial Black Gadget, sans-serif !important;;border-color:inherit;text-align:left;vertical-align:top}
.tg .tg-fymr{font-weight:bold;border-color:inherit;text-align:left;vertical-align:top}
</style>
<table class=tg>
  <tr>
    <th class=tg-u5pr>Domain</th>
    <th class=tg-u5pr>Total Servers</th>
    <th class=tg-u5pr>Servers with Successful Data Extraction</th>
    <th class=tg-u5pr>Servers Up But Failed Data Extraction</th>
    <th class=tg-u5pr>Servers Currently Down</th>
  </tr>
  <tr>
    <td class=tg-fymr>Domain1</td>
    <td class=tg-8ot9>$domain1_count</td>
    <td class=tg-8ot9>$domain1_success</td>
    <td class=tg-8ot9>$domain1_partial_success</td>
    <td class=tg-8ot9>$domain1_failed</td>
  </tr>
  <tr>
    <td class=tg-fymr>Domain2</td>
    <td class=tg-8ot9>$domain2_count</td>
    <td class=tg-8ot9>$domain2_success</td>
    <td class=tg-8ot9>$domain2_partial_success</td>
    <td class=tg-8ot9>$domain2_failed</td>
  </tr>
  <tr>
    <td class=tg-fymr>Domain3</td>
    <td class=tg-8ot9>$domain3_count</td>
    <td class=tg-8ot9>$domain3_success</td>
    <td class=tg-8ot9>$domain3_partial_success</td>
    <td class=tg-8ot9>$domain3_failed</td>
  </tr>
  <tr>
    <td class=tg-fymr>Domain4</td>
    <td class=tg-8ot9>$domain4_count</td>
    <td class=tg-8ot9>$domain4_success</td>
    <td class=tg-8ot9>$domain4_partial_success</td>
    <td class=tg-8ot9>$domain4_failed</td>
  </tr>
  <tr>
    <td class=tg-fymr>Domain5</td>
    <td class=tg-8ot9>$domain5_count</td>
    <td class=tg-8ot9>$domain5_success</td>
    <td class=tg-8ot9>$domain5_partial_success</td>
    <td class=tg-8ot9>$domain5_failed</td>
  </tr>
  <tr>
    <td class=tg-fymr>Domain6</td>
    <td class=tg-8ot9>$domain6_count</td>
    <td class=tg-8ot9>$domain6_success</td>
    <td class=tg-8ot9>$domain6_partial_success</td>
    <td class=tg-8ot9>$domain6_failed</td>
  </tr>
</table> 

<br>
<b>Script start time :</b> $start_time
<br>
<b>Script completion time :</b> $end_time
<br>
<b>Script Path :</b> D:\Scripts\uptime-patch.ps1 on <b>$env:COMPUTERNAME</b> 
<br>
<b>Script Running as :</b> $env:USERDNSDOMAIN\$env:USERNAME
<br>
<b>Archive Path :</b> D:\Reports\
<br> "

Send-MailMessage -From $From -To $To -cc $cc -Attachments $attachment -SmtpServer $smtp -Subject $Subject -Body $Body -BodyAsHtml

######END######
