##Author: Arvinder Dhar
##Description : This script will check all users and if a user has multiple group membership for groups 1 - group 5, username along with the group membership will be displayed

##Important: Run the script using elevated rights
##Updated version will have feature to send the result via e-mail

[array]$group1 =(Get-ADGroupMember "group 1").name
[array]$group2 =(Get-ADGroupMember "group 2").name
[array]$group3 =(Get-ADGroupMember "group 3").name
[array]$group4 =(Get-ADGroupMember "group 4").name
[array]$group5 =(Get-ADGroupMember "group 5").name

$value1 = diff $group1 ($group2 + $group3 + $group4 + $group5) -IncludeEqual -ExcludeDifferent -PassThru
$value2 = diff $group2 ($group3 + $group4 + $group5) -IncludeEqual -ExcludeDifferent -PassThru
$value3 = diff $group3 ($group4 + $group5) -IncludeEqual -ExcludeDifferent -PassThru
$value4 = diff $group4 $group5 -IncludeEqual -ExcludeDifferent -PassThru

$final = ($value1 + $value2 + $value3 + $value4) | select -Unique | Out-File user.txt

$users = Get-Content .\user.txt

foreach ($user in $users)

{
    Write-Host "$user is having multiple group membership"
    Write-Host ""

    "Groups of $user are:"

    $sam = (Get-ADUser -Filter { Displayname -like $user -or samaccountname -like $user} -Properties *).SamAccountName

    (Get-ADPrincipalGroupMembership $sam).name

    Write-Host ""
}

Remove-Item .\user.txt
