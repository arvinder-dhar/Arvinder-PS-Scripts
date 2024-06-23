[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$TimeNow = Get-Date
$24hrsAgo = $TimeNow.AddHours(-24)
$Date = Get-Date -Format MM-dd-yyyy

$PSScriptPath = "D:\ScheduledTasks\AzureAD\Cloud_Object_Report"
$LogPath = "$PSScriptPath\Logs"
$Report_CloudOnlyUser = "$LogPath\CloudOnlyUser.csv"
$Report_UPNIssue = "$LogPath\UPNIssue.csv"

Connect-Graph -TenantId 'TenantId' -ClientId 'ClientId' -CertificateThumbprint 'CertificateThumbprint'

$MasterUserList = Get-MgUser -All -Property UserPrincipalName,CreatedDateTime,onPremisesSyncEnabled,OnPremisesLastSyncDateTime,OnPremisesImmutableId,AccountEnabled,OnPremisesProvisioningErrors `
| Select-Object UserPrincipalName,CreatedDateTime,onPremisesSyncEnabled,OnPremisesLastSyncDateTime,OnPremisesImmutableId,AccountEnabled,OnPremisesProvisioningErrors

$CloudOnlyUser = $MasterUserList.where{$_.onPremisesSyncEnabled -like ''}
$NonCloudUserWithCloudUPN = $MasterUserList.Where{($_.onPremisesSyncEnabled -notlike '') -and ($_.UserPrincipalName -match "@cloudupn") `
-and ($_.UserPrincipalName -notlike "Sync_AADCBox1*") -and ($_.UserPrincipalName -notlike "Sync_AADCBox2*")}

$CloudOnlyUser | Select-Object UserPrincipalName,CreatedDateTime,onPremisesSyncEnabled,OnPremisesLastSyncDateTime,OnPremisesImmutableId,AccountEnabled, `
@{n='OnPremisesProvisioningErrors';e={$_.OnPremisesProvisioningErrors[0].category}} | Export-Csv $Report_CloudOnlyUser -NoTypeInformation

$NonCloudUserWithCloudUPN | Select-Object UserPrincipalName,CreatedDateTime,onPremisesSyncEnabled,OnPremisesLastSyncDateTime,OnPremisesImmutableId,AccountEnabled, `
@{n= 'OnPremisesProvisioningErrors' ;e = {$_.OnPremisesProvisioningErrors[0].category}} | Export-Csv $Report_UPNIssue -NoTypeInformation

# Report
$HtmlOutput="<html><body>"
$HtmlOutput+="<h2 style='font-size:25px;font-family:Calibri;color:#6F9824''>Azure Object Level Report - $Date</h2>"
$HtmlOutput+="<BR>"

# Cloud Only User Report

        $TableReport = "<Table><TABLE style=`"font-size:11pt;font-family:Calibri`" BORDER=1><tr bgcolor=`"#D5D5D4`"><TD><B>Category</B></TD><TD><B>Count</B></TD></TR>"
        $TableReport += "<TD>Cloud Only Accounts</TD><TD>$($CloudOnlyUser.Count)</TD></TR>"
        $TableReport += "<TD>New Cloud only Accounts created in last 24 hrs.</TD><TD>$((($CloudOnlyUser | Where-Object{$_.CreatedDateTime -ge $24hrsAgo}) | Measure-Object).count)</TD></TR>"
        $TableReport += "<TD>Sync'd accounts with Cloud UPN</TD><TD>$($NonCloudUserWithCloudUPN.Count)</TD></TR>"
        $TableReport += "<TD>New Sync'd accounts with Cloud UPN in last 24 hrs.</TD><TD>$(($NonCloudUserWithCloudUPN | Where-Object{$_.whencreated -ge $24hrsAgo}).count)</TD></TR>"
        $TableReport += "</TABLE>"

    $HtmlBody+=$TableReport
    $HtmlBody+="<br>"

    $HtmlOutput += $HtmlBody
    $HtmlOutput += "</body></html>"

#Set Subject for email
$mailSubject = "Azure Object Level Report - $Date"
$attachment = @($Report_CloudOnlyUser,$Report_UPNIssue)
Send-MailMessage -From "something.here@gmail.com" -To "something.here@gmail.com" -SmtpServer smtpserver.com -Body $HtmlOutput -BodyAsHtml -Subject $mailSubject -Attachments $attachment

Disconnect-Graph
