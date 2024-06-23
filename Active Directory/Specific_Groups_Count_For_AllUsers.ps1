##Author : Arvinder
##Description : Script will get users in specific groups and get the count of groups per user

$users = @()
$report = $null
$final_report = @()
$group_count = $null
$groups = $null

$users = (Get-ADUser -Filter 'Name -like "*"' -Server "domain.name").samaccountname ##Change Domain name here

foreach ($user in $users) {

$report = "" | Select-Object UserName,GroupMembership,GroupCount

$report.UserName = $user

$group_count = (Get-ADPrincipalGroupMembership -Identity $user | Where-Object {$_.name -like "groupname"} | Measure-Object).count ##Change Group Name here

$groups = $null
$report.GroupCount = $group_count

if ( $group_count -eq 1) {
$report.GroupMembership += (Get-ADPrincipalGroupMembership -Identity $user | Where-Object {$_.name -like "groupname"}).name ##Change Group Name here
}

else {
$groups += (Get-ADPrincipalGroupMembership -Identity $user | Where-Object {$_.name -like "groupname"}).name -join "," | Out-String ##Change Group Name here
$report.GroupMembership += $groups
}

$report
[array]$final_report += $report

}

$final_report | Export-Csv c:\users\$env:username\desktop\Group_Report.csv -NoTypeInformation
