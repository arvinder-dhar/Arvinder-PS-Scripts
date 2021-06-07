######START######
<# Author : Arvinder

Version : 2

Changes : Included User accounts as well

Description : Report Computer and User accounts that have UAC value as Password not required , the report will be sent to Directory Services Team for analysis (if any)

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
For User accounts this theory doesn't apply 


https://activedirectoryfaq.com/2013/12/empty-password-in-active-directory-despite-activated-password-policy/

#>

######START######

$start = get-date -Format "MMM-dd-yyyy hh:mm:ss tt"

Set-Location "Report Path"

$users = @()
$computers = @()
$user_result = @()
$computer_result = @()
$final_user_result = @()
$final_computer_result = @()

$DomainList = ("domain1","domain2","domain3","domain4","domain5","domain6")

foreach ($Domain in $DomainList) {

  $users += Get-ADUser -Properties useraccountcontrol -Server $Domain -LDAPFilter `
  "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=32)(!userAccountControl:1.2.840.113556.1.4.803:=2080))" `
  | Where-Object {$_.enabled -eq $true} | Select-Object samaccountname,@{N = "Domain"; E = {$Domain}}

  $computers += Get-ADComputer -Filter 'useraccountcontrol -band 32' -Properties useraccountcontrol -Server $Domain `
  | Where-Object {$_.enabled -eq $true} | Select-Object samaccountname,@{N = "Domain"; E = {$Domain}}

}

foreach($user in $users) {

 try {

   $user_result = "" | Select-Object Samaccountname,Name,Domain,DistinguishedName,passwordlastset,UAC

   $user_Domain = $user.Domain
   $user_samaccountname = $user.samaccountname
   $user_data = $null
   $user_data = Get-ADUser $user_samaccountname -Properties passwordlastset,useraccountcontrol -Server $user_Domain

   $user_result.Samaccountname = $user_samaccountname
   $user_result.Name = $user_data.Name
   $user_result.Domain = $user_Domain
   $user_result.DistinguishedName = $user_data.DistinguishedName
   $user_result.passwordlastset = $user_data.passwordlastset
   $user_result.UAC = $user_data.useraccountcontrol

   [array]$final_user_result += $user_result

   }


 catch {

   $user_result = "" | Select-Object Samaccountname,Name,Domain,DistinguishedName,passwordlastset,UAC

   $user_Domain = $user.Domain
   $user_samaccountname = $user.samaccountname

   $user_result.Samaccountname = $user_samaccountname
   $user_result.Name = "Retrieval failed"
   $user_result.Domain = $user_Domain
   $user_result.DistinguishedName = "NA"
   $user_result.passwordlastset = "NA"
   $user_result.UAC = "NA"

   [array]$final_user_result += $user_result

   }

 }

 
 foreach($computer in $computers) {

  try {
 
    $computer_result = "" | Select-Object Samaccountname,Name,Domain,DistinguishedName,passwordlastset,UAC
 
    $computer_Domain = $computer.Domain
    $computer_samaccountname = $computer.samaccountname
    $computer_data = $null
    $computer_data = Get-ADComputer $computer_samaccountname -Properties passwordlastset,useraccountcontrol -Server $computer_Domain
 
    $computer_result.Samaccountname = $computer_samaccountname
    $computer_result.Name = $computer_data.Name
    $computer_result.Domain = $Computer_Domain
    $computer_result.DistinguishedName = $computer_data.DistinguishedName
    $computer_result.passwordlastset = $computer_data.passwordlastset
    $computer_result.UAC = $computer_data.useraccountcontrol
 
    [array]$final_computer_result += $computer_result
 
    }
 
 
  catch {
 
    $computer_result = "" | Select-Object Samaccountname,Name,Domain,DistinguishedName,passwordlastset,UAC
 
    $computer_Domain = $computer.Domain
    $computer_samaccountname = $computer.samaccountname
 
    $computer_result.Samaccountname = $computer_samaccountname
    $computer_result.Name = "Retrieval failed"
    $computer_result.Domain = $computer_Domain
    $computer_result.DistinguishedName = "NA"
    $computer_result.passwordlastset = "NA"
    $computer_result.UAC = "NA"
 
    [array]$final_computer_result += $computer_result
 
    }
 
  }
  

$currentdate = (Get-Date).ToShortDateString()

$final_user_result | Export-Csv "Users-PasswordNotRequired-$currentdate.csv".Replace("/","-") -NoTypeInformation
$final_computer_result | Export-Csv "Computers-PasswordNotRequired-$currentdate.csv".Replace("/","-") -NoTypeInformation

$From = "abc@xyz.com"
$To = "cdf@xyz.com"
$attachment = @("Users-PasswordNotRequired-$currentdate.csv".Replace("/","-"),("Computers-PasswordNotRequired-$currentdate.csv".Replace("/","-")))
$smtp = "Smtp server"
$Body_part = Get-Date -Format "MMM-dd-yyyy"
$Subject = "Report : Users-Computers PasswordNotRequired $Body_part"

$domain1_user_count = ($users.Domain -like "domain1" | Measure-Object).count
$domain2_user_count = ($users.Domain -like "domain2" | Measure-Object).count
$domain3_user_count = ($users.Domain -like "domain3" | Measure-Object).count
$domain4_user_count = ($users.Domain -like "domain4" | Measure-Object).count
$domain5_user_count = ($users.Domain -like "domain5"| Measure-Object).count
$domain6_user_count = ($users.Domain -like "domain6" | Measure-Object).count


$domain1_computer_count = ($computers.Domain -like "domain1" | Measure-Object).count
$domain2_computer_count = ($computers.Domain -like "domain2" | Measure-Object).count
$domain3_computer_count = ($computers.Domain -like "domain3" | Measure-Object).count
$domain4_computer_count = ($computers.Domain -like "domain4" | Measure-Object).count
$domain5_computer_count = ($computers.Domain -like "domain5"| Measure-Object).count
$domain6_computer_count = ($computers.Domain -like "domain6" | Measure-Object).count

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
    <th class=tg-7ldo><span style=font-weight:bold>User Count</span></th>
    <th class=tg-7ldo><span style=font-weight:bold>Computer Count</span></th>
  </tr>
  <tr>
    <td class=tg-0lax>domain1</td>
    <td class=tg-dg7a>$domain1_user_count</td>
    <td class=tg-dg7a>$domain1_computer_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain2</td>
    <td class=tg-dg7a>$domain2_user_count</td>
    <td class=tg-dg7a>$domain2_computer_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain3</td>
    <td class=tg-dg7a>$domain3_user_count</td>
    <td class=tg-dg7a>$domain3_computer_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain4</td>
    <td class=tg-dg7a>$domain4_user_count</td>
    <td class=tg-dg7a>$domain5_computer_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain5</td>
    <td class=tg-dg7a>$domain5_user_count</td>
    <td class=tg-dg7a>$domain5_computer_count</td>
  </tr>
  <tr>
    <td class=tg-0lax>domain6</td>
    <td class=tg-dg7a>$domain6_user_count</td>
    <td class=tg-dg7a>$domain6_computer_count</td>
  </tr>
</table>

<br>
<b>Task Start time :</b> $start
<br>
<b>Task Info :</b> Weekly Report for Enabled User & Computer accounts with UAC : Password Not required
<br>
<b>Script Path :</b> Script Path
<br>
<b>Report Path :</b> Report Path
<br>  "

Send-MailMessage -From $From -To $To -Attachments $attachment -SmtpServer $smtp -Subject $Subject -Body $body -BodyAsHtml

######END######
