##Author: Arvinder Dhar

##Description: Helpdesk users can use this script to create/enable/disable/password_reset user accounts based on certain parameters

Import-module activedirectory

$value=Read-Host " Enter the value for task:

1 for Account Enable

2 for Account Disable

3 for Password Reset

4 for New User Account creation " 

###For enabling User

if ($value -eq "1" )

{
$account = Read-Host "enter the User-id that needs to be enabled"
Set-ADUser -Identity $account -Enabled $true
}

##For Disabling User

if ($value -eq "2" )

{
$account = Read-Host "enter the User-id that needs to be Disabled"
Set-ADUser -Identity $account -Enabled $false
}

##Password Reset

if ($value -eq "3" )

{
 $acc= Read-Host " enter the user-id for which password needs to be changed"
 $psd = Read-Host " enter the new password"
 $SecPaswd= ConvertTo-SecureString –String "$psd" –AsPlainText –Force

 Set-ADAccountPassword -Reset -NewPassword $SecPaswd –Identity $acc

 }

### User creation

if ($value -eq "4"){

$first= Read-host "enter the first name"
$Sur= Read-Host "enter the last name"
$desc= Read-Host "enter the Eid"
$sam = Read-Host "enter the login id"
$temp= Read-Host "enter the template account"
$psd1 = Read-Host "enter the password"

<# To get Template account OU location

Method 1 : 

$UserDN = (Get-ADUser -LDAPFilter "(samaccountname=$temp)").distinguishedname
[array]$tempArr = $UserDN.Split(",")
$tempArr2 = @()

For ($DNLoop=1; $DNLoop -lt $tempArr.Length; $DNLoop++)
{$tempArr2 += $tempArr[$DNLoop]}

$OU = [system.string]::Join(",",$tempArr2) 

#>

<# Method 2 : 



$UserDN = (Get-ADUser -LDAPFilter "(samaccountname=$temp)").distinguishedname
$ou = (([adsi]"LDAP://$UserDN").Parent).Replace("LDAP://","") #>

<# Method 3 :

$ou = $template.DistinguishedName -replace '^cn=.+?(?<!\\),'#>

$template = Get-ADUser -Identity $temp

New-ADUser -Name "$first $sur" -GivenName $first -Surname $sur -DisplayName "$first $sur" -AccountPassword (ConvertTo-SecureString -String "$psd1" -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true -SamAccountName $sam -Description $desc -Path $ou

Get-ADUser -Identity $temp -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $sam

}
