<# Author : Arvinder

Description : Find Computer accounts that have UAC value as Password not required , the report will be sent to Directory Services Team for analysis (if any)
This Report can be modified to include user accounts in the report as well, Just add this line for user accounts

Get-ADUser -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol <or>
Get-ADUser -Filter {PasswordNotRequired -eq $true} <or>
Get-ADUser -LDAPFilter "(userAccountControl:1.2.840.113556.1.4.803:=32)"

Domains : 
        1. Domain1
        2. Domain2
        3. Domain3
        4. Domain4
        5. Domain5
        6. Domain6

HTML Editor Reference URL's : 
    1. https://www.w3schools.com/html/  
    2. https://www.tablesgenerator.com/html_tables

Context & Best Practices :
The PASSWD_NOTREQD setting allows principals with reset password permissions to set a NULL value for an account password, or in other words, a password is not required. 
Principals do not typically have the reset password permission on their own accounts. By default, only elevated users such as account operators and domain administrators have reset password permission.
If an account has a NULL password, then anyone can log into the account and access resources the account is authorized to access.

Note that when you join a computer to a domain, either by using NETDOM or interactively by editing the System properties on the computer to be joined, the PASSWD_NOTREQD flag does not get set; 
but if you pre-create computer accounts by using Active Directory Users and Computers or the Active Directory Administrative Center, the PASSWD_NOTREQD flag can become enabled.

https://activedirectoryfaq.com/2013/12/empty-password-in-active-directory-despite-activated-password-policy/

#>

######START######

$start = get-date -Format "MMM-dd-yyyy hh:mm:ss tt"

cd "D:\ScheduledTasks\Directory\ADAudit\UAC-Password-Required\Audit-Reports"

$computers = @()
$result = @()
$final_result = @()

$DomainList = ("Domain1","Domain2","Domain3","Domain4","Domain5","Domain6") # If the usecase is to get data from trusted domains, use get-adtrust cmdlet

foreach ($Domain in $DomainList) {

$computers += Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server $Domain | select samaccountname,@{N = "Domain"; E = {$Domain}}
  
}

foreach($Computer in $computers) {


try {

$result = "" | select Samaccountname,Name,Domain,DistinguishedName,passwordlastset,UAC

$Computer_Domain = $Computer.Domain
$samaccountname = $Computer.samaccountname
$data = Get-ADComputer $samaccountname -Properties * -Server $Computer_Domain

$result.Samaccountname = $samaccountname
$result.Name = $data.Name
$result.Domain = $Computer_Domain
$result.DistinguishedName = $data.DistinguishedName
$result.passwordlastset = $data.passwordlastset
$result.UAC = $data.useraccountcontrol

#$result
[array]$final_result += $result

}


catch {
$result = "" | select Samaccountname,Name,Domain,DistinguishedName,passwordlastset,UAC

$samaccountname = $Computer.samaccountname
$result.Samaccountname = $samaccountname
$result.Name = "Check the Box"
$result.Domain = "NA"
$result.DistinguishedName = "NA"
$result.passwordlastset = "NA"
$result.UAC = "NA"

#$result
[array]$final_result += $result

}

}

$currentdate = (Get-Date).ToShortDateString()

$final_result | Export-Csv "PasswordNotRequired_$currentdate.csv".Replace("/","-") -NoTypeInformation

$From = "Reports@xyz.com"
$To = "abc@xyz.com"
$attachment = @("PasswordNotRequired_$currentdate.csv".Replace("/","-"))
$smtp = "smtp.server.com"
$Body_part = Get-Date -Format "MMM-dd-yyyy"
$Subject = "Report Computers PasswordNotRequired $Body_part"
$end = get-date -Format "MMM-dd-yyyy hh:mm:ss tt"

$domain1_count = ((Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server domain1).samaccountname | Measure-Object).count
$domain2_count = ((Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server domain2).samaccountname | Measure-Object).count
$domain3_count = ((Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server domain3).samaccountname | Measure-Object).count
$domain4_count = ((Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server domain4).samaccountname | Measure-Object).count
$domain5_count = ((Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server domain5).samaccountname | Measure-Object).count
$domain6_count = ((Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server domain6).samaccountname | Measure-Object).count

$body = "<style type=text/css>
.tg  {border-collapse:collapse;border-color:#aaa;border-spacing:0;}
.tg td{background-color:#fff;border-color:#aaa;border-style:solid;border-width:1px;color:#333;
  font-family:Arial, sans-serif;font-size:14px;overflow:hidden;padding:10px 5px;word-break:normal;}
.tg th{background-color:#f38630;border-color:#aaa;border-style:solid;border-width:1px;color:#fff;
  font-family:Arial, sans-serif;font-size:14px;font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
.tg .tg-7ldo{font-family:Arial Black, Gadget, sans-serif !important;;font-size:18px;text-align:left;vertical-align:top}
.tg .tg-0lax{text-align:left;vertical-align:top}
.tg .tg-dg7a{background-color:#FCFBE3;text-align:left;vertical-align:top}
</style>
<table class=tg>
  <tr>
    <th class=tg-7ldo><span style=font-weight:bold>Domain</span></th>
    <th class=tg-7ldo><span style=font-weight:bold>Computers with UAC PASSWD_NOTREQD</span></th>
  </tr>
  <tr>
    <td class=tg-0lax>domain1</td>
    <td class=tg-dg7a>$domain1_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain2</td>
    <td class=tg-dg7a>$domain2_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain3</td>
    <td class=tg-dg7a>$domain3_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain4</td>
    <td class=tg-dg7a>$domain4_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain5</td>
    <td class=tg-dg7a>$domain5_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain6.COM</td>
    <td class=tg-dg7a>$domain6_count</td>
  </tr>
</table>

<br>
<b>Task Start time :</b> $start
<br>
<b>Task Info :</b> This is Password not Required Report, Please work on the objects
<br>
<b>Script Path :</b> Script Path
<br>
<b>Report Path :</b> Script Report
<br>  "

Send-MailMessage -From $From -To $To -Attachments $attachment -SmtpServer $smtp -Subject $Subject -Body $body -BodyAsHtml

######END######
