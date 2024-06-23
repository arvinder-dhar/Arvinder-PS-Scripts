<#

Author : Arvinder

Description : MFA Method Used during sign-in (SMS and Auth App only)

#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

Set-Location \\somethingpath

########### Connection Logic ###########
Import-Module CredentialManager
$cred = Get-StoredCredential -Target Block
Connect-AzAccount -Credential $cred

Set-AzContext -SubscriptionId "SubscriptionId"

$users = ((Get-ADGroup group -Properties member).member | ForEach-Object { get-aduser $_ | Select-Object samaccountname }).samaccountname

$data = @()

$date_range = get-date -format yyyy-MM-dd

## data
foreach ($user in $users) {

    $query = "SigninLogs
    | where TimeGenerated between (datetime('2023-08-07') .. datetime($date_range))
    | where UserPrincipalName startswith '$user'
    | where AuthenticationRequirement contains 'MultiFactorAuthentication'
    | where (MfaDetail.authMethod contains 'Mobile app notification') or (MfaDetail.authMethod contains 'Passwordless Microsoft Authenticator') `
         or (MfaDetail.authMethod contains 'Text message')
    | order by TimeGenerated
    | project ['Time (UTC)'] = TimeGenerated,
    UserDisplayName,
    ['MFA Auth method']=MfaDetail.authMethod,
    ['Application Name']=AppDisplayName
"

    [array]$data += Invoke-AzOperationalInsightsQuery -WorkspaceId "LAWorkspaceId" -Query $query

}


$data | Select-Object -ExpandProperty results | Export-Csv Auth_Methods_Report.csv -NoTypeInformation

# Disconnect Azure Account
Disconnect-AzAccount
