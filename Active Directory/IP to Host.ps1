##This script will get the Hostname associated with the ip address fetched from servers.txt file

$final_result = @()
$test = $null
$servers = Get-Content C:\Users\$env:USERNAME\Desktop\servers.txt

foreach ( $server in $servers)

{

$test = [bool] ( Test-Connection $server -count 1 -ErrorAction SilentlyContinue )

If ($test -eq $true)

{
try{
$Result = "" | select IP_Address,Host_Name
$Result.IP_Address = $server
$Result.Host_Name = ([System.Net.Dns]::GetHostbyAddress("$server")).hostname

[array]$final_result += $Result
}

catch

{

$Result = "" | select IP_Address,Host_Name
$Result.IP_Address = $server
$Result.Host_Name = "No Hostname Found"

[array]$final_result += $Result

}

}

else

{

$Result = "" | select IP_Address,Host_Name
$Result.IP_Address = $server
$Result.Host_Name = "No Hostname Found"

[array]$final_result += $Result

}

}

$final_result
$final_result | Export-Csv IP.csv -NoTypeInformation