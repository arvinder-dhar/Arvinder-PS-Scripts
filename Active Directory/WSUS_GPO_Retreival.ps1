##Author : Arvinder Dhar
##Task: To Retreive GPO names with WSUS in the name for multiple domains

$domains = Get-Content .\domains.txt #Contains domain names in domains.txt file
$final_report = @()

foreach ($domain in $domains)

{
try {
$gpo_report = "" | Select-Object GPOName,GPODomain
$gpo_report.GPOName += (Get-GPO -all -Domain $domain | Where-Object {$_.displayname -like "*wsus*"}).Displayname -join "," | Out-String
$gpo_report.GPODomain += $domain
#(Get-GPO -all -Domain $domain | Where-Object {$_.displayname -like "*wsus*"}).DomainName -join "," | Out-String

$gpo_report
[array]$final_report += $gpo_report}

catch { #do nothing
}


}

$final_report
$final_report | Export-Excel GPOReport.xlsx -AutoSize