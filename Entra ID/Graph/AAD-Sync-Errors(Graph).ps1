<#
    Author : Arvinder
    Description : This Script is used to get details on Syncronization Errors in the PROD Azure AD tenant
    Scheduled on : Once a week and send a report to the intended audience
    Limitations : As of now Sync Errors only due to Category=PropertyConflict can be fetched, but this may be extended by MS.
    Environment : PROD Azure AD Tenant
    Version : 2
    Improvements : Graph PowerShell calls are been used instead of MSOL/AAD Module

KB's
  Credential Manager : https://petri.com/managing-usernames-passwords-powershell-sharepoint-online
  Work with odata next link
   Header : https://www.techguy.at/use-microsoft-graph-api-with-powershell-part-2/
   https://www.techguy.at/paging-in-microsoft-graph-rest-api/
  Backtick : https://stackoverflow.com/questions/69076658/using-filter-through-microsoft-graph-api-request

#>

####START####

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$date = Get-Date -Format "MMM-dd-yyyy"

#Set Location to the Parent Directory
Set-Location "D:\ScheduledTasks\Directory\AzureAD\AAD-Sync-Errors"

############
## Credential Manager Connection
Import-Module CredentialManager
$connection = Get-StoredCredential -Target Block

## ROPC Grant Flow
$TenantID = "tenantid"
$ClientId = "clientid"
$scope = "https://graph.microsoft.com/.default"
$loginURL = "https://login.microsoftonline.com"

$body = @{
  grant_type = "password";
  scope      = $scope;
  client_id  = $ClientID;
  username   = $connection.UserName;
  password   = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($connection.Password))
}

$token = Invoke-RestMethod -Method Post -Uri $("$loginURL/$tenantid/oauth2/v2.0/token") -Body $body

$datauri_users = "https://graph.microsoft.com/v1.0/users?`$select=id,displayName,onPremisesProvisioningErrors&`$filter=onPremisesProvisioningErrors/any(r:r/category eq 'PropertyConflict')" ## Backtick has to be used before $ or else it will get the data for API string before $
$datauri_groups = "https://graph.microsoft.com/v1.0/groups`?$select=onPremisesProvisioningErrors,displayName&`$filter=onPremisesProvisioningErrors/any(r:r/category eq 'PropertyConflict')"
$datauri_contacts = "https://graph.microsoft.com/v1.0/contacts`?$select=onPremisesProvisioningErrors,displayName&`$filter=onPremisesProvisioningErrors/any(r:r/category eq 'PropertyConflict')"

$headers = @{
  "Authorization"    = "Bearer $($token.access_token)"
  "Content-type"     = "application/json"
  "ConsistencyLevel" = 'eventual'
}

## Declare Data Variables 
$data_users_value = @()
$data_groups_value = @()
$data_contacts_value = @()

## Get Sync Error Data for Users
$data_users = Invoke-RestMethod -Headers $headers -Uri $datauri_users -Method Get
$data_users_value = $data_users.value
$next_datauri_users = $data_users."@odata.nextLink"

while ($next_datauri_users -ne $null) {

  $data_users = Invoke-RestMethod -Headers $headers -Uri $next_datauri_users -Method Get
  $next_datauri_users = $data_users."@odata.nextLink"
  $data_users_value += $data_users.value

}

## Get Sync Error Data for groups
$data_groups = Invoke-RestMethod -Headers $headers -Uri $datauri_groups -Method Get
$data_groups_value = $data_groups.value
$next_datauri_groups = $data_groups."@odata.nextLink"

while ($next_datauri_groups -ne $null) {

  $data_groups = Invoke-RestMethod -Headers $headers -Uri $next_datauri_groups -Method Get
  $next_datauri_groups = $data_groups."@odata.nextLink"
  $data_groups_value += $data_groups.value

}

## Get Sync Error Data for contacts
$data_contacts = Invoke-RestMethod -Headers $headers -Uri $datauri_contacts -Method Get
$data_contacts_value = $data_contacts.value
$next_datauri_contacts = $data_contacts."@odata.nextLink"

while ($next_datauri_contacts -ne $null) {

  $data_contacts = Invoke-RestMethod -Headers $headers -Uri $next_datauri_contacts -Method Get
  $next_datauri_contacts = $data_contacts."@odata.nextLink"
  $data_contacts_value += $data_contacts.value

}

############
Write-Host "Sync Error Count for Users : $($data_users_value.count)"
Write-Host "Sync Error Count for Groups : $($data_groups_value.count)"
Write-Host "Sync Error Count for Contacts : $($data_contacts_value.count)"
############

## Data Collection and export to CSV
$data_users_value | Select-Object id, displayname -ExpandProperty onPremisesProvisioningErrors -ErrorAction SilentlyContinue | `
  Select-Object `
@{n = 'Object Id'; e = { $_.id } }, `
@{n = 'Display Name'; e = { $_.displayname } }, `
@{n = 'Object Type'; e = { 'User' } }, `
@{n = 'Error Category'; e = { $_.category } }, `
@{n = 'Property Causing Error'; e = { $_.propertyCausingError } }, `
@{n = 'Property Value'; e = { $_.value } }, `
@{n = 'whenstarted'; e = { $_.occurredDateTime.split('.')[0] } } | Export-Csv "D:\ScheduledTasks\Directory\AzureAD\AAD-Sync-Errors\Reports\AAD-Sync-Errors-$date.csv" -NoTypeInformation -Append

$data_groups_value | Select-Object id, displayname -ExpandProperty onPremisesProvisioningErrors -ErrorAction SilentlyContinue | `
  Select-Object `
@{n = 'Object Id'; e = { $_.id } }, `
@{n = 'Display Name'; e = { $_.displayname } }, `
@{n = 'Object Type'; e = { 'Group' } }, `
@{n = 'Error Category'; e = { $_.category } }, `
@{n = 'Property Causing Error'; e = { $_.propertyCausingError } }, `
@{n = 'Property Value'; e = { $_.value } }, `
@{n = 'whenstarted'; e = { $_.occurredDateTime.split('.')[0] } } | Export-Csv "D:\ScheduledTasks\Directory\AzureAD\AAD-Sync-Errors\Reports\AAD-Sync-Errors-$date.csv" -NoTypeInformation -Append

$data_contacts_value | Select-Object id, displayname -ExpandProperty onPremisesProvisioningErrors -ErrorAction SilentlyContinue | `
  Select-Object `
@{n = 'Object Id'; e = { $_.id } }, `
@{n = 'Display Name'; e = { $_.displayname } }, `
@{n = 'Object Type'; e = { 'Contact' } }, `
@{n = 'Error Category'; e = { $_.category } }, `
@{n = 'Property Causing Error'; e = { $_.propertyCausingError } }, `
@{n = 'Property Value'; e = { $_.value } }, `
@{n = 'whenstarted'; e = { $_.occurredDateTime.split('.')[0] } } | Export-Csv "D:\ScheduledTasks\Directory\AzureAD\AAD-Sync-Errors\Reports\AAD-Sync-Errors-$date.csv" -NoTypeInformation -Append

############

## Mail Details
$From = "something.here@gmail.com"
$To = "something.here@gmail.com"
$smtp = "smtp"
$subject = "Weekly AAD Sync Error Report : $date"
$attachment = "Reports\AAD-Sync-Errors-$date.csv"
$Error_count = (Import-Csv $attachment | Measure-Object).count

$body = "<br>
<style type=text/css>
.tg  {border-collapse:collapse;border-spacing:0;}
.tg td{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  overflow:hidden;padding:10px 5px;word-break:normal;}
.tg th{border-color:black;border-style:solid;border-width:1px;font-family:Arial, sans-serif;font-size:14px;
  font-weight:normal;overflow:hidden;padding:10px 5px;word-break:normal;}
.tg .tg-0lax{text-align:left;vertical-align:top}
</style>
<table class=tg>
<thead>
  <tr>
    <th class=tg-0lax><span style=font-weight:bold>Scope (PROD)</span></th>
    <th class=tg-0lax><span style=font-weight:bold>AAD Sync Error Count (Property Conflict)</span></th>
  </tr>
</thead>
<tbody>
  <tr>
    <td class=tg-0lax>Azure Active Directory</td>
    <td class=tg-0lax>$Error_count</td>
  </tr>
</tbody>
</table>
<p class=MsoNormal align=center style='text-align:left'><span
style='font-family:'Arial',sans-serif'><img width=190 height=63
id='_x0000_i1025'
src='https://examlabpractice.com/wp-content/uploads/2023/10/Entra_ID_logo_square2.jpg'
style='height:1.5in;width:1.5in' alt=Image><o:p></o:p></span></p>
"

Send-MailMessage -From $From -To $To -SmtpServer $smtp -Subject $subject -Body $body -BodyAsHtml -Attachments $attachment
