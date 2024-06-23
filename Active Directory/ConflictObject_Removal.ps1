<# 
Description : Remove Conflict Objects from AD Domains (See $DomainList for Domain Info)
If object count is more than 20 , script will not remove any conflict object rather will ask to check the conflict objects manually

#>

$DomainList = ("domain1","domain2","domain3","domain4")
$outfilepath = "c:\Temp\ConflictObjectReport.csv"

$MasterConflictObjectList = @()

if(Test-Path $outfilepath){Remove-Item $outfilepath}

foreach($Domain in $DomainList)
{
    if($Domain -eq "domain1"){$searchbase = "dc=domain1,dc=xyz,dc=com"}
    if($Domain -eq "domain2"){$searchbase = "dc=domain2,dc=xyz,dc=com"}
	if($Domain -eq "domain3"){$searchbase = "dc=domain3,dc=xyz,dc=com"}
    if($Domain -eq "domain4"){$searchbase = "dc=domain4,dc=xyz,dc=com"}

    
    $conflictObjectList = $null
    $conflictObjectList = Get-ADObject -Filter {CN -like "*\0ACNF:*"} -Server $Domain -SearchBase $searchbase -SearchScope Subtree -Properties UserPrincipalName, Name, WhenCreated, `
    samAccountName, Description, ObjectClass, DistinguishedName | Where-Object{($_.ObjectClass -eq "User") -OR ($_.ObjectClass -eq "Group")} | Sort-Object -Descending ObjectClass, whencreated

    [array]$MasterConflictObjectList += $conflictObjectList

# Protect from Accidental Deletion Removed from conflict Objects Found 

Get-ADObject -Filter {CN -like "*\0ACNF:*"} -Server $Domain -SearchBase $searchbase -SearchScope Subtree | Where-Object {($_.ObjectClass -eq "User") -OR ($_.ObjectClass -eq "Group")} `
| ForEach-Object {Set-ADObject $_.DistinguishedName -ProtectedFromAccidentalDeletion:$false -Server $Domain }

}

# Remove Conflict Entries

if($MasterConflictObjectList.count -eq 0) { 
$subject = "Conflict Object Report -"+ (Get-Date).ToLongDateString()
Send-MailMessage -From "Reports@xyz.com" -To "ABC@xyz.com" -cc "abc@xyz.com" -Subject $subject -Body "No Conflict Objects Found" -SmtpServer "smtp.xyz.com"
 }

if($MasterConflictObjectList.count -le 20) {

	foreach($C_Object in $MasterConflictObjectList) {

        try{

        if ($C_Object.DistinguishedName.Contains("dc=domain1,dc=xyz,dc=com")) {$object_domain = "domain1" }
        if ($C_Object.DistinguishedName.Contains("dc=domain2,dc=xyz,dc=com")) {$object_domain = "domain2" }
        if ($C_Object.DistinguishedName.Contains("dc=domain3,dc=xyz,dc=com")) {$object_domain = "domain4" }
        if ($C_Object.DistinguishedName.Contains("dc=domain4,dc=xyz,dc=com")) {$object_domain = "domain3" }

        if (!( Remove-ADObject -Identity $C_Object.DistinguishedName -Confirm:$false -Server $object_domain )) {[array]$success_objects += $C_Object}
        }

        catch {
        [array]$failed_objects += $C_Object
        }
	}

if ($failed_objects) {

[string]$HtmlOutput="<HTML><BODY style=`"font-size:11pt;font-family:Calibri`">"
$HtmlOutput+= "<U><B><FONT SIZE=3>Active Directory Conflict Object Report</U></B> - " + (Get-Date).ToLongDateString() + "</font><BR><BR>"
$HtmlOutput+= "<B>Domain Name</B> : " + ($DomainList -join ", ") + "<BR>"
$HtmlOutput+= "<B>Below Conflict Objects were Removed</B> " + "<BR>"

$TableReport = "<Table><TABLE style=`"font-size:11pt;font-family:Calibri`" BORDER=1><tr bgcolor=`"#D5D5D4`"><TD><B>UserPrincipalName</B></TD><TD><B>Name</B></TD><TD><B>whencreated</B></TD><TD><B>samAccountname</B></TD><TD><B>Description</B></TD><TD><B>ObjectClass</B></TD><TD><B>DistinguishedName</B></TD></TR>"
foreach ($item in $success_objects)
{
    $TableReport += "<TD>$($item.UserPrincipalName)</TD><TD>$($item.Name)</TD><TD>$($item.whencreated)</TD><TD>$($item.samAccountname)</TD><TD>$($item.Description)</TD><TD>$($item.ObjectClass)</TD><TD>$($item.DistinguishedName)</TD></TR>"
}
$TableReport += "</TABLE>"

$HtmlOutput2= "<B>Below Conflict Objects Couldn't Be Removed</B>,Please Check them Manually " + "<BR>"

$TableReport2 += "<Table><TABLE style=`"font-size:11pt;font-family:Calibri`" BORDER=1><tr bgcolor=`"#D5D5D4`"><TD><B>UserPrincipalName</B></TD><TD><B>Name</B></TD><TD><B>whencreated</B></TD><TD><B>samAccountname</B></TD><TD><B>Description</B></TD><TD><B>ObjectClass</B></TD><TD><B>DistinguishedName</B></TD></TR>"
foreach ($item2 in $failed_objects)
{
    $TableReport2 += "<TD>$($item2.UserPrincipalName)</TD><TD>$($item2.Name)</TD><TD>$($item2.whencreated)</TD><TD>$($item2.samAccountname)</TD><TD>$($item2.Description)</TD><TD>$($item2.ObjectClass)</TD><TD>$($item2.DistinguishedName)</TD></TR>"
}
$TableReport2 += "</TABLE>"

$Footer = "<HTML><BODY style=`"font-size:11pt;font-family:Calibri`">"
$Footer += "<BR><B>Script running as user:</B> $ENV:USERDNSDOMAIN\$ENV:USERNAME"
$Footer += "<BR><B>Script path:</B> $PSScriptRoot on $ENV:COMPUTERNAME</BODY></HTML>"


$MailMessage = "<BR>$HtmlOutput</BR><BR>$TableReport</BR><BR><BR>$HtmlOutput2</BR><BR>$TableReport2</BR><BR>$Footer</BR>"

If($MasterConflictObjectList)
{
$subject = "Conflict Object Report -"+ (Get-Date).ToLongDateString()

Send-MailMessage -From "Reports@xyz.com" -To "ABC@xyz.com" -cc "abc@xyz.com" -Subject $subject  -BodyAsHtml -Body  $MailMessage  -SmtpServer "smtp.xyz.com"
}

}

else {

[string]$HtmlOutput="<HTML><BODY style=`"font-size:11pt;font-family:Calibri`">"
$HtmlOutput+= "<U><B><FONT SIZE=3>Active Directory Conflict Object Report</U></B> - " + (Get-Date).ToLongDateString() + "</font><BR><BR>"
$HtmlOutput+= "<B>Domain Name</B> : " + ($DomainList -join ", ") + "<BR>"
$HtmlOutput+= "<B>Below Conflict Objects were Removed</B> " + "<BR>"

$TableReport = "<Table><TABLE style=`"font-size:11pt;font-family:Calibri`" BORDER=1><tr bgcolor=`"#D5D5D4`"><TD><B>UserPrincipalName</B></TD><TD><B>Name</B></TD><TD><B>whencreated</B></TD><TD><B>samAccountname</B></TD><TD><B>Description</B></TD><TD><B>ObjectClass</B></TD><TD><B>DistinguishedName</B></TD></TR>"
foreach ($item in $success_objects)
{
    $TableReport += "<TD>$($item.UserPrincipalName)</TD><TD>$($item.Name)</TD><TD>$($item.whencreated)</TD><TD>$($item.samAccountname)</TD><TD>$($item.Description)</TD><TD>$($item.ObjectClass)</TD><TD>$($item.DistinguishedName)</TD></TR>"
}

$TableReport += "</TABLE>"

$Footer = "<HTML><BODY style=`"font-size:11pt;font-family:Calibri`">"
$Footer += "<BR><B>Script running as user:</B> $ENV:USERDNSDOMAIN\$ENV:USERNAME"
$Footer += "<BR><B>Script path:</B> $PSScriptRoot on $ENV:COMPUTERNAME</BODY></HTML>"

$MailMessage = "<BR>$HtmlOutput</BR><BR>$TableReport</BR><BR>$Footer</BR>"

If($MasterConflictObjectList)
{
$subject = "Conflict Object Report -"+ (Get-Date).ToLongDateString()

Send-MailMessage -From "Reports@xyz.com" -To "ABC@xyz.com" -cc "abc@xyz.com" -Subject $subject  -BodyAsHtml -Body  $MailMessage  -SmtpServer "smtp.xyz.com"
}

}

}

if($MasterConflictObjectList.count -gt 20) { 
$subject = "Conflict Object Report -"+ (Get-Date).ToLongDateString()
Send-MailMessage -From "Reports@xyz.com" -To "ABC@xyz.com" -cc "abc@xyz.com" -Subject $subject -Body "No Conflict Objects Deleted Since the Count is more than 20" -SmtpServer "smtp.xyz.com"
 }
