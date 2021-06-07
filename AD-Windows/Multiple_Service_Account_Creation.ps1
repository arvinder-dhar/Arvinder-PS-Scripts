##Author: Arvinder
##Description: The script will create Service account on several domains fetched from the notepad file 

$domains = Get-Content .\Domains.txt

foreach($domain in $domains){

$remote= [bool](Test-WSMan -ComputerName $domain -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $domain -Quiet

if ($remote -eq "True" -and $ping -eq "True")
{

$first= "Service Account"
$sam = "serviceaccount"

$template = Get-ADUser -Identity mtsuser -Server $domain
$ou = $template.DistinguishedName -replace '^cn=.+?(?<!\\),'

New-ADUser -Name $first -GivenName $first -DisplayName $first -AccountPassword (ConvertTo-SecureString -String "@ct!us3r" -AsPlainText -Force) `
-Enabled $true -PasswordNeverExpires $true -CannotChangePassword $true -SamAccountName $sam -Path $ou -Server $domain

Set-ADUser -Identity serviceaccount -Server $domain -Description "Service account created from Script"

$Groups =(Get-ADPrincipalGroupMembership -Identity user1 -Server $domain).name # Copy group membership from user1 to service account

foreach ($Group in $Groups)

{

$Group_list = Get-ADGroup -Identity $Group -Server $domain

Add-ADPrincipalGroupMembership -Identity serviceaccount -MemberOf $Group_list -Server $domain

}

}

else {Write-Warning "$domain not reachable"}

}

