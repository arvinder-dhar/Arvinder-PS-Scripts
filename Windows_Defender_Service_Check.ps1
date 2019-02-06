# Author : Arvinder
# Description : To retreive servers list which have windows defender installed on them

$domains = (Get-ADTrust -Filter 'name -like "*"').name


foreach ($domain in $domains) {

try{

[array]$Hosting_servers += (Get-ADComputer -Filter { Name -like "*" } -Properties * -Server $domain ).DNSHostname 
[array]$MyHosting_servers += (Get-ADComputer -Filter { Name -like "*" } -Properties * ).DNSHostname

[array]$servers = ($Hosting_servers + $MyHosting_servers) | select -Unique
}

catch { #do nothing

}

}

$final_report = @()

Foreach( $server in $servers) {

$service_status = [bool](Get-Service -ComputerName $server | Where-Object {$_.DisplayName -like "windows defender service"})

if ($service_status -eq $true) {

$report = "" | select ServerName,WindowsDefService,ServiceStatus
$report.ServerName = $server
$report.WindowsDefService = (gsv -ComputerName $server | Where-Object {$_.DisplayName -like "windows defender service"}).displayname
$report.ServiceStatus = (gsv -ComputerName $server | Where-Object {$_.DisplayName -like "windows defender service"}).status

$report
[array]$final_report += $report

}

}