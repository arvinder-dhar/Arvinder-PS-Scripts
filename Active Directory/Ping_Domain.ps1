##Author: Arvinder
### Get Ping status and domain name of Computers accounts fetched from file

$report = @()
$final_report = @()
[array]$Data = Get-Content .\list.txt

foreach ($machine in $Data) {

    $report = "" | Select-Object Hostname,ping_status,Domain_Name
    $ping = Test-Connection -ComputerName $machine -Count 1 -Quiet
    $fqdn = [System.Net.Dns]::GetHostByName($machine).hostname
    $domain = $fqdn.Substring($fqdn.IndexOf(".") + 1)

    $report.Hostname = $machine
    $report.ping_status = $ping
    $report.Domain_Name = $domain
    
    $report
    [array]$final_report += $report


}

$final_report | Export-Csv servers.csv -NoTypeInformation
