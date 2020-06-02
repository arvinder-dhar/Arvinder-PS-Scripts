####START####

<# Author: Arvinder
  Short Description : Script will track bad password count for Service account

  Notification will be send via e-mail to team members, if any incorrect password is used for the SRV Account

#>         

for($i=1; $i -le 10000; $i++)
{   

$badpasswordtime= $null
$newbadpasswordtime = $null

$badpasswordtime= (Get-ADUser -Identity account -Server PDCe -Properties *).badPasswordTime 

$formatted_time = [DateTime]::FromFileTime($badpasswordtime)

Write-Host ""
Write-Host "Checking Bad Password Count...." -ForegroundColor Green
Write-Host "Last Bad Password Time : $formatted_time" -ForegroundColor Green
Write-Host ""

start-sleep 60

$account_value = (Get-ADUser -Identity account -Server PDCe -Properties *)

$newbadpasswordtime= $account_value.badPasswordTime 
$badpasswordcount = $account_value.badPwdCount

$formatted_time_new = [DateTime]::FromFileTime($newbadpasswordtime)

if ($badpasswordtime -ne $newbadpasswordtime){

Write-Warning "Bad Password Found"

$data =[ordered] @{
 'User Account' = "srvarsacct" ;
 'Bad Password Time' = $formatted_time_new ;
 'Bad Password Count' = $badpasswordcount ;
      }

$subject = "SRV Account Lockout Report"
$smtp = "smtp.xyz.com"
$From = "Reports@xyz.com"
$To = "abc@xyz.com"
$cc = "def@xyz.com"

Send-MailMessage -From $From -To $To -cc $cc -SmtpServer $smtp -Subject $Subject -Body ($data | Out-String)

}

} 
         

<#if ("C:\Users\$env:username\desktop\srv_account_bad_password_data.csv") {Remove-Item "C:\Users\$env:username\desktop\srv_account_bad_password_data.csv"}

$Object = New-Object -TypeName PSObject -Property $data
$Object | Export-Csv "cd C:\Users\$env:username\desktop\srv_account_bad_password_data.csv" -NoTypeInformation

$attachment = @("C:\Users\$env:username\desktop\srv_account_bad_password_data.csv") #>

####END####
