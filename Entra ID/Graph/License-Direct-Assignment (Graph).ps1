<#
    Author : Arvinder
    Description : This Script will run Weekly and send report for users that have direct License Assignment
    Environment : PROD Azure AD Tenant
    Version : 2
    Improvements : Graph calls are been used instead of the legacy PowerShell Modules

KB : https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-ps-examples#check-if-user-license-is-assigned-directly-or-inherited-from-a-group
     https://jeffbrown.tech/powershell-hash-table-pscustomobject/
     https://azurecloudai.blog/2022/04/11/azure-license-management-with-microsoft-graph/
#>

####START####

## Stopwatch Start
$StopWatch = [System.Diagnostics.Stopwatch]::StartNew()
$StopWatch.Start()
$date = Get-Date -Format "MM-dd-yyyy"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Set Location to the Parent Directory
Set-Location "somethingpath"

## Move last 20 Reports to Archive folder

if ((Get-ChildItem .\Reports | Where-Object { $_.name -notlike "archive" } | Measure-Object).count -ge 20) {

  (Get-ChildItem .\Reports | Where-Object { $_.name -notlike "archive" }).name | `
    ForEach-Object { Move-Item -Path .\Reports\$_ -Destination .\Reports\Archive -Verbose }
}

## Declare Variables
$All_AADUser_Details = @()
$report = @()

## Connect MG Graph
Connect-Graph -TenantId 'TenantId' -ClientId 'ClientId' -CertificateThumbprint 'CertificateThumbprint'

## Get all User details along with License Assignment States
[array]$All_AADUser_Details += Get-MgUser -All -Property Id, OnPremisesSyncEnabled, DisplayName, UserPrincipalName, LicenseAssignmentStates, accountEnabled `
| Select-Object Id, OnPremisesSyncEnabled, DisplayName, UserPrincipalName, LicenseAssignmentStates, accountEnabled

## To avoid throttle
start-sleep 120

## License SKU Details in hashtable format for quick search
$skusHash = @{}
Get-MgSubscribedSku | ForEach-Object { $skusHash[$_.SkuId] = $_.SkuPartNumber }

## Get Group Details
$grouphash = @{}
$All_AADUser_Details.LicenseAssignmentStates.assignedByGroup | Select-Object -unique | ForEach-Object { $grouphash[$_] = (Get-MgGroup -GroupId $_).DisplayName } # Get the display name of the each of the groups

## Get User License Details
[array]$report += foreach ($user in $all_AADUser_Details) {
  
  if ($user.licenseAssignmentStates) { 
    $licenseassignments = $user.licenseAssignmentStates
    foreach ($license in $licenseassignments) {
      $group = $null
      try { $group = $grouphash[$license.AssignedByGroup] }
      catch { $group = "Direct Assignment" }

      [PSCustomObject]@{
        'ID'                = $user.id
        'On-Premises Sync'  = $user.onPremisesSyncEnabled
        'Display Name'      = $user.displayName
        'UserPrincipalName' = $user.userPrincipalName
        'License SkuId'     = $license.SkuId
        'License Name'      = $skusHash[$license.SkuId]
        'Group'             = $group
        'State'             = $license.State
      }
    }
  }
}

# Show elapsed script run time
$StopWatch.Stop()
[string]$ScriptElapsedTime = [string]::Format("{0}h:{1}m:{2}s", $StopWatch.Elapsed.Hours, $StopWatch.Elapsed.Minutes, $StopWatch.Elapsed.Seconds)

## Attachment for email
#$final_report | Where-Object { $_.AssignedDirectly -eq $true } | Export-Csv .\Reports\Direct_License_Assignment_$date.csv -NoTypeInformation -Append
$report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -notlike '') }  | Export-Csv .\Reports\Direct_License_Assignment_$date.csv -NoTypeInformation -Append

## Mail Details
$From = "something.here@gmail.com"
$To = "something.here@gmail.com"
$smtp = "smtpserver.com"
$subject = "Weekly Report : Direct License Assignment($date)"

## Body Data (Include the License that you would like to monitor or Include all, choice is yours)
$exo_plan2 = ($report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -like 'EXCHANGEENTERPRISE') } | Measure-Object).count 
$powerapps_per_user = ($report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -like 'POWER_BI_PRO') } | Measure-Object).count 
$pbi_pro = ($report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -like 'POWER_BI_PRO') } | Measure-Object).count 
$E5 = ($report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -like 'SPE_E5') } | Measure-Object).count
$Viva = ($report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -like 'WORKPLACE_ANALYTICS') } | Measure-Object).count
$E3 = ($report.where{ ($_.Group -like 'Direct*') -and ($_.'License Name' -like 'EMS') } | Measure-Object).count

# Show elapsed script run time
$StopWatch.Stop()
[string]$ScriptElapsedTime = [string]::Format("{0}h:{1}m:{2}s", $StopWatch.Elapsed.Hours, $StopWatch.Elapsed.Minutes, $StopWatch.Elapsed.Seconds)

# Disconnect MS Graph
Disconnect-Graph

$body = "<br>
<style type=text/css>
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
    <th class=tg-7ldo><span style=font-weight:bold>License SKU</span></th>
    <th class=tg-7ldo><span style=font-weight:bold>Product Name</span></th>
    <th class=tg-7ldo><span style=font-weight:bold>Direct Assignment Count</span></th>
  </tr>
  <tr>
    <td class=tg-dg7a>tenant:EXCHANGEENTERPRISE</td>
    <td class=tg-dg7a>Exchange Online (Plan 2)</td>
    <td class=tg-0lax>$exo_plan2</td>
  </tr>
  <tr>
    <td class=tg-dg7a>tenant:POWERAPPS_PER_USER</td>
    <td class=tg-dg7a>Power Apps per user plan</td>
    <td class=tg-0lax>$powerapps_per_user</td>
  </tr>
  <tr>
    <td class=tg-dg7a>tenant:POWER_BI_PRO</td>
    <td class=tg-dg7a>Power BI Pro</td>
    <td class=tg-0lax>$pbi_pro</td>
  </tr>
  <tr>
    <td class=tg-dg7a>tenant:SPE_E5</td>
    <td class=tg-dg7a>Microsoft 365 E5</td>
    <td class=tg-0lax>$E5</td>
  </tr>
  <tr>
    <td class=tg-dg7a>tenant:WORKPLACE_ANALYTICS</td>
    <td class=tg-dg7a>Microsoft Viva Insights</td>
    <td class=tg-0lax>$Viva</td>
  </tr>
  <tr>
    <td class=tg-dg7a>tenant:EMS</td>
    <td class=tg-dg7a>Enterprise Mobility + Security E3</td>
    <td class=tg-0lax>$E3</td>
  </tr>
</table>

<br>
<b>Job Execution time :</b> $ScriptElapsedTime
<br>
<b>Brief Description :</b> Only Critical Licenses are displayed in above table. For full Direct License Assignment report, please refer attachment.
<br>

<p class=MsoNormal align=center style='text-align:left'><span
style='font-family:'Arial',sans-serif'><img width=190 height=63
id='_x0000_i1025'
src='https://examlabpractice.com/wp-content/uploads/2023/10/Entra_ID_logo_square2.jpg'
style='height:1.5in;width:1.5in' alt=Image><o:p></o:p></span></p>"

$attachment = @("Reports\Direct_License_Assignment_$date.csv")

Send-MailMessage -From $From -To $To -SmtpServer $smtp -Subject $subject -Body $body -BodyAsHtml -Attachments $attachment

####END####
