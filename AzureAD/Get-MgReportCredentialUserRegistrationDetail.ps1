<#
Author : Arvinder

Description : Used to pull MgReportCredentialUserRegistrationDetail report

KB's
  https://learn.microsoft.com/en-us/graph/api/reportroot-list-credentialuserregistrationdetails?view=graph-rest-beta&tabs=powershell

#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set Directory location to the parent
Set-Location 'somethingpath'

## Connect MS Graph
Connect-MgGraph -TenantId "TenantId" -AppId "AppId" -CertificateThumbprint "CertificateThumbprint"
Select-MgProfile beta

#Delete Previous day report (if any)
Remove-Item MgReportCredentialUserRegistrationDetail.csv -Force
Start-Sleep 10

Get-MgReportCredentialUserRegistrationDetail -All | Select-Object Id, UserPrincipalName, @{n = 'AuthMethods'; e = { $_.AuthMethods } }  | export-csv MgReportCredentialUserRegistrationDetail.csv -Append -NoTypeInformation
Start-Sleep 10

## check if the report is present post above command execution
if (Test-Path MgReportCredentialUserRegistrationDetail.csv) {
  Send-MailMessage -From "something.here@gmail.com" -To "something.here@gmail.com" -Subject "CredentialUserRegistrationDetail Report (Success)" -SmtpServer smtpserver.com -Body "User RegistrationDetail Report Run Complete"
  
}

# check if the complete report is exported or if there is a need to re-run a new one
if ((Import-Csv .\MgReportCredentialUserRegistrationDetail.csv | Measure-Object).count -lt 170000) {

  Send-MailMessage -From "something.here@gmail.com" -To "something.here@gmail.com" -Subject "CredentialUserRegistrationDetail Report (Re-run)" -SmtpServer smtpserver.com -Body "User RegistrationDetail Report was not Complete, re-running the same. Please check post second success email" -Priority High

  ## Disconnect MS Graph
  Disconnect-MgGraph
  Start-Sleep 10
 
  ## Connect MS Graph
  Connect-MgGraph -TenantId "TenantId" -AppId "AppId" -CertificateThumbprint "CertificateThumbprint"
  Select-MgProfile beta

  Remove-Item MgReportCredentialUserRegistrationDetail.csv -Force
  Start-Sleep 10

  # Re-run the report
  Get-MgReportCredentialUserRegistrationDetail -All | Select-Object Id, UserPrincipalName, @{n = 'AuthMethods'; e = { $_.AuthMethods } }  | export-csv MgReportCredentialUserRegistrationDetail.csv -Append -NoTypeInformation

  if (Test-Path MgReportCredentialUserRegistrationDetail.csv) {
    Send-MailMessage -From "something.here@gmail.com" -To "something.here@gmail.com" -Subject "CredentialUserRegistrationDetail Report (Success) (Second Run)" -SmtpServer smtpserver.com -Body "Second User RegistrationDetail Report Run Complete, please check if report is sufficient or needs manual run" -Priority High
    
  }
}

## Disconnect MS Graph
Disconnect-MgGraph

##############
