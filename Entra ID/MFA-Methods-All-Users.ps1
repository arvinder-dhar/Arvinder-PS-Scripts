<#
Author : Arvinder

Description : This script will be used to Generate Report for Users that have Strong Authentication MFA method(s) enabled
Further Seggregation is done on the report on the basis of below parameters

1. Total Users
2. MFA stamped amongst them
3. Two Methods
4. One Method
5. Country Wise Distribution
6. Any AAD Roles assigned


Properties 
ObjectID,UPN,Dirsynced,Corpid,admin_role,mfastatus,ssprstatus,phoneauth,appauth,helloforbusiness,emailauth,passwordless,fido

KB Article : https://docs.microsoft.com/en-us/graph/api/resources/authenticationmethods-usage-insights-overview?view=graph-rest-beta
https://lazyadmin.nl/powershell/msgraph-mfa-status/

#>

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Change to the Published DFS Location
Set-Location \\somethingpath

# Delete Previous Day Report
Remove-Item .\MFA-Methods-All-Users.csv -Force
Start-Sleep 5

Function Connect-Graph {

  Connect-MgGraph -TenantId "TenantId" -AppId "AppId" -CertificateThumbprint "CertificateThumbprint"
  Select-MgProfile -Name beta

}

Function Get-AllAADUsers {

  ## Credential Manager Connection
  Import-Module CredentialManager

  $connection = Get-StoredCredential -Target Block
  $datauri_users = "https://graph.microsoft.com/beta/users/?`$select=Id,OnPremisesSyncEnabled,DisplayName,GivenName,UserPrincipalName,UserType"

  ## ROPC Grant Flow
  $TenantID = "TenantID"
  $ClientId = "ClientId"
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

  $headers = @{
    "Authorization"    = "Bearer $($token.access_token)"
    "Content-type"     = "application/json"
    "ConsistencyLevel" = 'eventual'
  }

  ## Declare Data Variables 
  $data_users_value = @()

  ## Get Sync Error Data for Users
  $data_users = Invoke-RestMethod -Headers $headers -Uri $datauri_users -Method Get
  $data_users_value = $data_users.value
  $next_datauri_users = $data_users."@odata.nextLink"

  while ($next_datauri_users -ne $null) {

    $data_users = Invoke-RestMethod -Headers $headers -Uri $next_datauri_users -Method Get
    $next_datauri_users = $data_users."@odata.nextLink"
    $data_users_value += $data_users.value

  }

  $data_users_value

}

Function Get-AdminRoleObjectIds {
  # Get all users with an Admin role
  [CmdletBinding()]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory = $false,
      ValueFromPipelineByPropertyName = $true,
      Position = 0)]
    $Param1
  )
  process {
    $admins = Get-MgDirectoryRole | Where-Object { $_.DisplayName -like "*Admin*" } | `
      ForEach-Object { Get-MgDirectoryRoleMember -DirectoryRoleId $_.Id | Where-Object { $_.AdditionalProperties."@odata.type" -eq "#microsoft.graph.user" } } | `
      ForEach-Object { Get-MgUser -userid $_.id } | Select-Object Id # @{Name="Role"; Expression = {$role}}, DisplayName, UserPrincipalName, Mail | Sort-Object -Property Mail -Unique
    
    return $admins
  }

}

Function Get-MFAMethods {

  param(
    [Parameter(Mandatory = $true)] $ObjectId
  )
  process {
    # Get MFA details for each user
    [array]$mfaData = Get-MgUserAuthenticationMethod -UserId $ObjectId

    # Create MFA details object
    $mfaMethods = [Ordered]@{
      'MFA Status'               = "" ;
      'Authentication Number'    = "" ;
      'Authenticator App'        = "" ;
      'Authenticator App Device' = "" ;
      'PasswordLess Status'      = "" ;
      'PasswordLess Device'      = "" ;
      'SSPR Capable'             = "" ;
      'SSPR Email'               = "" ;
      'FIDO'                     = "" ;
      'FIDO Device Model'        = "" ;
      'OATH Auth'                = "" ;
      'Hello For Business'       = "" ;
    }

    ForEach ($method in $mfaData) {

      Switch ($method.AdditionalProperties["@odata.type"]) {

        "#microsoft.graph.phoneAuthenticationMethod" { 
          # Phone authentication
          #$mfaMethods.'Phone Authentication' = $true
          $mfaMethods.'Authentication Number' = $method.AdditionalProperties["phoneType", "phoneNumber"] -join ' '
          $mfaMethods.'MFA Status' = "enabled"
        } 

        "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod" { 
          # Microsoft Authenticator App
          $mfaMethods.'Authenticator App' = $true
          $mfaMethods.'Authenticator App Device' = $method.AdditionalProperties["displayName"] 
          $mfaMethods.'MFA Status' = "enabled"
        } 

        "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod" { 
          # Passwordless
          $mfaMethods.'PasswordLess Status' = $true
          $mfaMethods.'PasswordLess Device' = $method.AdditionalProperties["displayName"]
          $mfaMethods.'MFA Status' = "enabled"
        }

        "#microsoft.graph.emailAuthenticationMethod" { 
          # Email Authentication
          #$mfaMethods.'SSPR Status' = $true
          $mfaMethods.'SSPR Email' = $method.AdditionalProperties["emailAddress"] 
          #$mfaMethods.'MFA Status' = "enabled"
        }  

        "#microsoft.graph.fido2AuthenticationMethod" { 
          # FIDO2 key
          $mfaMethods.FIDO = $true
          $mfaMethods.'FIDO Device Model' = $method.AdditionalProperties["model"]
          $mfaMethods.'MFA Status' = "enabled"
        }

        "#microsoft.graph.softwareOathAuthenticationMethod" { 
          # ThirdPartyAuthenticator
          $mfaMethods.'OATH Auth' = $true
          $mfaMethods.'MFA Status' = "enabled"
        }

        "#microsoft.graph.windowsHelloForBusinessAuthenticationMethod" { 
          # Windows Hello
          $mfaMethods.'Hello For Business' = $true
          #$mfaMethods.'MFA Status' = "enabled"
        } 
             
             
        "#microsoft.graph.passwordAuthenticationMethod" { 
          # Password
          # When only the password is set, then MFA is disabled.
          if ($mfaMethods.'MFA Status' -ne "enabled") { $mfaMethods.'MFA Status' = "disabled" }
          if ($mfaMethods.'MFA Status' -eq "enabled" -and $mfaMethods.'Authentication Number' -ne $null) { $mfaMethods.'SSPR Capable' = "True" }
          if ($mfaMethods.'MFA Status' -eq "disabled" -or $mfaMethods.'Authentication Number' -eq $null) { $mfaMethods.'SSPR Capable' = "False" }
        }
                   
        <# "microsoft.graph.temporaryAccessPassAuthenticationMethod" { 
            # Temporary Access pass
            $mfaMethods.tempPass = $true
            $tempPassDetails = $method.AdditionalProperties["lifetimeInMinutes"]
           # $mfaMethods.'MFA Status' = "enabled"
          } #>
      }
    }
    Return $mfaMethods
  }
}

Function Get-FinalMFAReport {

  param(
    [Parameter(Mandatory = $true)] $Object
  )

  process {

    $mfa_methods = Get-MFAMethods -ObjectId $Object.Id
    $DirSync = $Object.onPremisesSyncEnabled

    #Admin Role Check Logic
    $adminaccount = $AADAdminObjectIDs.Id.Contains($Object.Id)

    if ($DirSync -eq $true) {
      
      $upn = $Object.UserPrincipalName
      $upn = $upn.Split('@')[0] + "@onprem.com"
  
      $corpaccount = (Get-ADUser -Filter { userprincipalname -like $upn }).samaccountname

      $Finalreport = [ordered]@{
        'Display Name'             = $Object.DisplayName
        'Object ID'                = $Object.Id
        'User Principal Name'      = $upn
        'Directory Synced'         = "True"
        'Corp Account'             = $corpaccount
        'Admin Role(AAD)'          = $adminaccount
        'MFA Status'               = $mfa_methods.'MFA Status' ;
        'Authentication Number'    = $mfa_methods.'Authentication Number' ;
        'Authenticator App'        = $mfa_methods.'Authenticator App' ;
        'Authenticator App Device' = $mfa_methods.'Authenticator App Device' ;
        'PasswordLess Status'      = $mfa_methods.'PasswordLess Status' ;
        'PasswordLess Device'      = $mfa_methods.'PasswordLess Device' ;
        'SSPR Capable'             = $mfa_methods.'SSPR Capable' ;
        'SSPR Email'               = $mfa_methods.'SSPR Email' ;
        'FIDO'                     = $mfa_methods.'FIDO' ;
        'FIDO Device Model'        = $mfa_methods.'FIDO Device Model' ;
        'OATH Auth'                = $mfa_methods.'OATH Auth' ;
        'Hello For Business'       = $mfa_methods.'Hello For Business' ;
      }

      $Obj = New-Object -TypeName PSObject -Property $Finalreport 
      Write-Output $Obj

    }

    if ($DirSync.length -eq 0) {

      $Finalreport = [ordered]@{
        'Display Name'             = $Object.DisplayName
        'Object ID'                = $Object.Id
        'User Principal Name'      = $upn
        'Directory Synced'         = "False"
        'Corp Account'             = "NA"
        'Admin Role(AAD)'          = $adminaccount
        'MFA Status'               = $mfa_methods.'MFA Status' ;
        'Authentication Number'    = $mfa_methods.'Authentication Number' ;
        'Authenticator App'        = $mfa_methods.'Authenticator App' ;
        'Authenticator App Device' = $mfa_methods.'Authenticator App Device' ;
        'PasswordLess Status'      = $mfa_methods.'PasswordLess Status' ;
        'PasswordLess Device'      = $mfa_methods.'PasswordLess Device' ;
        'SSPR Capable'             = $mfa_methods.'SSPR Capable' ;
        'SSPR Email'               = $mfa_methods.'SSPR Email' ;
        'FIDO'                     = $mfa_methods.'FIDO' ;
        'FIDO Device Model'        = $mfa_methods.'FIDO Device Model' ;
        'OATH Auth'                = $mfa_methods.'OATH Auth' ;
        'Hello For Business'       = $mfa_methods.'Hello For Business' ;
      }

      $Obj = New-Object -TypeName PSObject -Property $Finalreport 
      Write-Output $Obj

    }

  

  }

}

#Initiate Functions Run

Connect-Graph
#Connect-AAD

$All_Users = Get-AllAADUsers
$AADAdminObjectIDs = Get-AdminRoleObjectIds

foreach ($user in $All_Users) {

  Get-FinalMFAReport -Object $user | Export-Csv MFA-Methods-All-Users.csv -NoTypeInformation -Append

} 

Disconnect-MgGraph

##############
