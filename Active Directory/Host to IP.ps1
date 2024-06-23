##This script will get the IP address associated with the respective hostnames that will be fetched to it via a text file

$final_result = $null
$servers = Get-Content .\Servers.txt

foreach ( $server in $servers)

{

$test = $null
$test = [bool] ( Test-Connection $server -count 1 -ErrorAction SilentlyContinue )

If ( $test -eq $true)

{

$Result = "" | select Server_name, IP_Address
$Result.Server_name = $server
$Result.IP_Address = ((Test-Connection $server -count 1).IPV4Address).IPAddressToString

[array]$final_result += $Result

}

else

{

$Result = "" | select Server_name, IP_Address
$Result.Server_name = $server
$Result.IP_Address = "No IP"

[array]$final_result += $Result

}

}

$final_result
$final_result | Export-Csv IP.csv -NoTypeInformation