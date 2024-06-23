# Author : Arvinder
# Description : To retreive servers list which have windows defender installed on them

$domains = (Get-ADTrust -Filter 'name -like "*"').name


foreach ($domain in $domains) {

try{

[array]$servers_1 += (Get-ADComputer -Filter { Name -like "*" } -Properties * -Server $domain ).DNSHostname 
[array]$servers_2 += (Get-ADComputer -Filter { Name -like "*" } -Properties * ).DNSHostname

[array]$servers = ($servers_1 + $servers_2) | Select-Object -Unique
}

catch { #do nothing

}

}

$final_report = @()

Foreach( $server in $servers) {

$service_status = [bool](Get-Service -ComputerName $server | Where-Object {$_.DisplayName -like "windows defender service"})

if ($service_status -eq $true) {

$report = "" | Select-Object ServerName,WindowsDefService,ServiceStatus
$report.ServerName = $server
$report.WindowsDefService = (Get-Service -ComputerName $server | Where-Object {$_.DisplayName -like "windows defender service"}).displayname
$report.ServiceStatus = (Get-Service -ComputerName $server | Where-Object {$_.DisplayName -like "windows defender service"}).status

$report
[array]$final_report += $report

}

}
