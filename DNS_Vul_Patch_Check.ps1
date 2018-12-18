## Author : Arvinder
## Description : Script finds out the DC's that are missing patch to mitigate Windows DNS Server Heap Overflow Vulnerability (CVE-2018-8626)
## For More: https://portal.msrc.microsoft.com/en-US/security-guidance/advisory/CVE-2018-8626

$dcs = $null
$result = $null
$final_result = $null
Remove-Item c:\users\$env:username\desktop\DNS_Server_Vuln.xlsx

$dcs = Get-Content C:\users\$env:username\desktop\dc.txt # Dc's in dc.txt file or you can pull directly list from ADDS PS Cmdlet

foreach ($dc in $dcs) {

$ping = Test-Connection -ComputerName $dc -Quiet

if ($ping -eq "True") {

$os = (Get-WmiObject -ComputerName $dc -Class win32_operatingsystem).caption

if ($os -like "Microsoft Windows Server 2012*") {

$result = "" | select DC_Name,os,kb4471320,kb4471322,kb4471321,uptime,patchtime

$result.DC_Name = $dc
$result.os = (Get-WmiObject -ComputerName $dc -Class win32_operatingsystem).caption

$kb4471320 = [bool](Get-HotFix -ComputerName $dc -Id KB4471320 -ErrorAction SilentlyContinue)
$kb4471322 = [bool](Get-HotFix -ComputerName $dc -Id KB4471322 -ErrorAction SilentlyContinue)

if ($kb4471320 -eq $true) {$result.kb4471320 = "True"}

else {$result.kb4471320 = "False"}

if ($kb4471322 -eq $true) {$result.kb4471322 = "True"}

else {$result.kb4471322 = "False"}

$result.kb4471321 = "NA"

$Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $dc -ErrorAction SilentlyContinue
$startdate = $Boot.ConvertToDateTime($Boot.LastBootUpTime)

$patchdate = (Get-WmiObject -Class win32_quickfixengineering -ComputerName $dc -ErrorAction SilentlyContinue | sort InstalledOn -Descending | select -First 1).InstalledOn
$EndDate =  Get-Date
$uptime = (New-TimeSpan -Start $startdate -End $EndDate).days

$result.Uptime = $uptime

$patch_days =  (New-TimeSpan -Start $patchdate -End $EndDate).days
$result.patchtime = $patch_days

$result
[array]$final_result += $result

}

if ($os -like "Microsoft Windows Server 2016*") {

$result = "" | select DC_Name,os,kb4471320,kb4471322,kb4471321,uptime,patchtime

$result.DC_Name = $dc
$result.os = (Get-WmiObject -ComputerName $dc -Class win32_operatingsystem).caption

$result.kb4471320 = "NA"
$result.kb4471322 = "NA"

$kb4471321 = [bool](Get-HotFix -ComputerName $dc -Id KB4471321 -ErrorAction SilentlyContinue)

if ($kb4471321 -eq $true) {$result.kb4471321 = "True"}

else {$result.kb4471321 = "False"}

$Boot = Get-WmiObject -Class win32_operatingsystem -ComputerName $dc -ErrorAction SilentlyContinue
$startdate = $Boot.ConvertToDateTime($Boot.LastBootUpTime)

$patchdate = (Get-WmiObject -Class win32_quickfixengineering -ComputerName $dc -ErrorAction SilentlyContinue | sort InstalledOn -Descending | select -First 1).InstalledOn
$EndDate =  Get-Date
$uptime = (New-TimeSpan -Start $startdate -End $EndDate).days

$result.Uptime = $uptime

$patch_days =  (New-TimeSpan -Start $patchdate -End $EndDate).days
$result.patchtime = $patch_days

$result
[array]$final_result += $result

}

}

else {

$result = "" | select DC_Name,os,kb4471320,kb4471322,kb4471321,uptime,patchtime

$result.DC_Name = $dc
$result.os = "Server Not Reachable"
$result.kb4471320 = "NA"
$result.kb4471322 = "NA"
$result.kb4471321 = "NA"
$result.uptime = "NA"
$result.patchtime = "NA"

$result
[array]$final_result += $result

}

}

$final_result
$final_result | Export-Excel c:\users\$env:username\desktop\DNS_Server_Vuln.xlsx -AutoSize
