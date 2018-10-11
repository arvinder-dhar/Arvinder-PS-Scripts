### Start ###

## Description: Complete Certain tasks after AD trust has been built

## Task : Terminal server local admin account tasks

$computer = Read-Host "Enter the FQDN of MGT Server"
$Password = Read-Host "Enter the New Local Admin Password"

$admin = [adsi]"WinNT://$computer/Administrator"
$admin.UserFlags.value = $admin.UserFlags.value -bor 0x10000
$admin.CommitChanges()

$admin.SetPassword("$Password")

Write-Verbose "Local admin password reset done for Server:$computer`nPlease verify by login" -Verbose

## Task : Pre-FSMO Backup configuration tasks

Import-Module ServerManager 
Add-WindowsFeature Windows-Server-Backup

$Backup_Psd = Read-Host "Enter the New Password for Backup Account"

$secure_Backup_psd= ConvertTo-SecureString –String $Backup_Psd –AsPlainText –Force
Set-ADAccountPassword -Reset -NewPassword $secure_Backup_psd –Identity backupaccount

Set-ADUser -Identity backupaccount -PasswordNeverExpires $true -CannotChangePassword $true -Enabled $true

[array]$Backup_Groups = "abc","xyz"

foreach ($Backup_Group in $Backup_Groups) 
{
Add-ADGroupMember -Identity $Backup_Group -Members "backupaccount"
}

$cred_backup = Get-Credential -Message "Enter Domain Credentials for Backup Account Config"
$Admin_Backup_group = Get-ADGroup -Identity Admin_Backup_group -Server main.fqdn -Credential $cred_backup

Add-ADPrincipalGroupMembership -Identity backupaccount -MemberOf $Admin_Backup_group -Server main.fqdn -Credential $cred_backup

Write-Verbose "Backup Tasks completed, please refer the last message for pending manual tasks" -Verbose

<# Below tasks have to be done manually for FSMO Backup Config
   Backup Window :  12:30AM and 3:30AM 
   For SUW, use \\abc.server\Backups 
   For SAC, use \\xyz.server\Backups
#>

# Task : Pre-Monitoring Tool Installation tasks

$monitor_Psd = Read-Host "Enter the Monitoring Tool Account Password"

$secure_monitor_psd= ConvertTo-SecureString –String $monitor_Psd –AsPlainText –Force
Set-ADAccountPassword -Reset -NewPassword $secure_monitor_psd –Identity monitoraccount

Set-ADUser -Identity monitoraccount -PasswordNeverExpires $true -CannotChangePassword $true -Enabled $true

[array]$monitor_Groups = "AD_ADM","Enterprise_ENT_DCServiceLogon_SEC","Enterprise_ENT_DenyADWrites_SEC","Enterprise_ENT_Deny-SA-Logon_SEC"

foreach ($monitor_Group in $monitor_Groups)
{

Add-ADGroupMember -Identity $monitor_Group -Members "monitoraccount"

}

Write-Verbose "Monitor Tool Tasks completed, please refer the last message for pending manual tasks" -Verbose

<# Below tasks have to be done manually for Montoring Tool Setup

Create c:\directory directory if the directory already exists – DELETE ALL CONTENTS!
Open CMD.exe window and put yourself in the empty c:\directory (run as administrator)
FTP **** (****/****)
Inside of ftp 
Enter in “bin” and then “hash” to get it in binary mode and showing hash progress
cd certain path
ls *DC* and find the name of the ***.exe file	
currently that is “***.exe”
get ****.exe
#>

## Task: Domain Administrator Account tasks

$check = $null
$domain = Read-Host "Enter the Domain Name"

try { $check = [bool]((Get-ADUser -Identity administrator -Server $domain).SamAccountName)}

catch { Write-Warning "No account with logon id:'Administrator' found" }

if ($check -eq $true) { 

$Domain_Psd = Read-Host "Enter the New Domain Admin Password"

$Secure_Domain_psd= ConvertTo-SecureString –String $Domain_Psd –AsPlainText –Force
Set-ADAccountPassword -Reset -NewPassword $Secure_Domain_psd –Identity administrator -Server $domain

$Name = Read-Host "Enter the New Display and logon Name"

Set-ADUser -Identity administrator -PasswordNeverExpires $true -DisplayName $Name -SamAccountName $Name -Server $domain -PassThru | Rename-ADObject -NewName $Name

Write-Verbose "Admin account for Domain:$Domain has been Updated successfully`nPlease logoff and Login with new Creds" -Verbose

}

Write-Verbose "All Post-Trust Tasks Completed, Please complete the below pending tasks Manually:`n`n1.Configuring FSMO BackUp manually from Server Manager`n2.Monitoring Tool Installation on DC's & Terminal server`n3.Delete the WSUS-Temporary GPO link to the /#sitecode# container`n4.Add Customer DNS Suffix in GPO " -Verbose

### END ###