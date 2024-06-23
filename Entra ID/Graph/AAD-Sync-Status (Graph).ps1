<#
Author : Arvinder
Description :  The task will send an alert to Azure AD Global Admins in case the lat Azure AD Sync time is > 2 hrs.
Modules : MS Graph PowerShell

#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

#Connection logic
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

## Connect to MG Graph
Connect-MgGraph -AccessToken $token.access_token

$Company_info = Get-MgOrganization
$Last_AAD_Sync_Time = $Company_info.OnPremisesLastSyncDateTime
$Current_Time = (Get-Date).ToUniversalTime()

$Sync_time_Span = (New-TimeSpan -Start $Last_AAD_Sync_Time -End $Current_Time).Hours

if ($Sync_time_Span -ge 2) {
    $primary_AAD_Sync_Server = "Graph PS Limitation" #Use MSOL Commands to get the value till this limitation is over

    $body = "
    <font
    color=Red><font size='+2'><b>ALERT : Last AAD Export Sync Duration > 2 Hrs.</b><br>
    <font
    color=Black size='+1.5'><b>Please check the run cycles and confirm they are running correctly
    <ul><li>
    <b>Primary Sync Server:</b> $primary_AAD_Sync_Server</li>
    <li><b>LastDirsync Time(UTC):</b> $Last_AAD_Sync_Time </li>
    </ul>
    <br>
    <img src=cid:att><br><br>
"
    $msg = new-object Net.Mail.MailMessage
    $smtp = new-object Net.Mail.SmtpClient("smtp.server.com")
    $msg.From = "something.here@gmail.com"
    $msg.To.Add("something1.here@gmail.com")
    $msg.To.Add("something2.here@gmail.com")
    $msg.Subject = "PROD : AAD Sync Delay"
    $msg.Body = $body
    $msg.IsBodyHTML = $true
    $msg.Priority = "High"

    $att = new-object Net.Mail.Attachment("D:\ScheduledTasks\Directory\AzureAD\AAD-Sync-Status\logo.png")
    $att.ContentType.MediaType = "image/png"
    $att.ContentId = "att"
    $msg.Attachments.Add($att)
    $smtp.Send($msg)
    $att.Dispose()

}

Disconnect-MgGraph
