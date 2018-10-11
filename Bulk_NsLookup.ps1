##Author: Arvinder
### Get Nslookup info from bulk of IPs
### Next phase : export the data to excel with live ouput been fetched on excel/text file


[array]$Info = Get-Content .\IP.txt

foreach ($ip in $Info) {

try {

    $Details = "" | Select Hostname, IP
    $Machine = ([System.Net.DNS]::GetHostEntry("$ip")).HostName
    $address = (([System.Net.DNS]::GetHostEntry("$ip")).AddressList).IPAddressToString
  
    $Details.Hostname = $Machine
    $Details.IP = $address
  
    [array]$final_result += $Details   

}

catch {

    $Details = "" | Select Hostname, IP
   
    $Details.Hostname = "Cannot Nslookup for $ip"
    $Details.IP = $null
  
    [array]$final_result += $Details

}

}

$final_result | Out-File .\result.txt
$final_result = $null