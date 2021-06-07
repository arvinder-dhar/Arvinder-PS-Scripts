##Author: Arvinder
## Description : The script will set the DNS scavenging to 30 days for all Trusted Domains

$servers = $null
$Trusted_Domains = $null

[array]$Trusted_Domains = (Get-ADTrust -Filter *).name

foreach ($Trust in $Trusted_Domains)
{

$remote= [bool](Test-WSMan -ComputerName $Trust -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $Trust -Quiet

if ($remote -eq "True" -and $ping -eq "True")
{

[array]$servers += $Trust

}

else { Write-Warning "$Trust Domain is not reachable"}

}

Write-Host ""

foreach ($server in $servers)

{

Set-DnsServerScavenging -ComputerName $server -ScavengingState $true -RefreshInterval 30.00:00:00 -NoRefreshInterval 30.00:00:00 -ScavengingInterval 30.00:00:00 -ApplyOnAllZones
Write-Verbose "Scavenging Set to 30 Days on Domain : $server" -Verbose

}