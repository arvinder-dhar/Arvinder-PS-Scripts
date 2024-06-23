<#
Description : Snippets to call Microsoft Graph Endpoint for a particular client registerd in an Azure AD Tenant and retreive token 
The Retreived token will be eventually used to further work on the resources based on the scope's (Delegated and Application) approved on the client id

Important : The Curl snippets will not run properly in powershell if you use only curl instead of curl.exe
If you wish to use the former one, run the full command (without .exe) in Bash or native windows command prompt
#>

########################################################
######################### Client Credentials ######################### 
########################################################

## CURL
curl.exe -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "client_id=<client-id>&scope=https%3A%2F%2Fgraph.microsoft.com%2F.default&client_secret=<client-secret>&grant_type=client_credentials" --url "https://login.microsoftonline.com/{tenant-id}/oauth2/v2.0/token"

## PowerShell

$ClientID = "<Client-Id>"
$ClientSecret = "<Client-Secret>"
$loginURL = "https://login.microsoftonline.com"
$tenantid = "<Tenant-Id>"
$scope = "https://graph.microsoft.com/.default"

$body = @{
  grant_type="client_credentials";
  scope=$scope;
  client_id=$ClientID;
  client_secret=$ClientSecret
  }

  $token = Invoke-RestMethod -Method Post -Uri $("$loginURL/$tenantid/oauth2/v2.0/token") -Body $body

  <# 
  #####################Utilize the Token#########################
  
  In Case of Client-Credentials, the client id used in the Grant flow needs to have the intended API (Application) Permissions
  
  For example, in this case We are trying to get other user details and to get the  data, We need Only below permission.
    1. Client ID has "User.read.all" Application API Permission
    NOTE : Application Permissions are like super-admin permissions, and once granted they have unrestricted access on the scope granted. So Be very careful while granting the Application Permission  
    Detailed API permissions for all resources that can be called via Graph API, Refer : https://docs.microsoft.com/en-us/graph/overview?view=graph-rest-1.0
  
  #>
  
  $DataUrl = "https://graph.microsoft.com/v1.0/users/user-upn"
  
  ## Get Data
  Invoke-RestMethod -Headers @{Authorization = "Bearer $($token.access_token)"} -Uri $DataUrl -Method Get

#### Below One Pending
<#

Include case of refresh token

Include below as well with little explanation of use case,,, limitations and advantages
  1. Implicit grant flow
  2. auth code grant
  3. on-behalf of flow
  4. device code flow
  5. SAML Bearer Assertion flow (Used by other folks,, heavy testing to be involved,... in absence of lab, incorporate Corporate lab and deduce results)
    https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-saml-bearer-assertion
    
  ## Short documentation links for access token, id token, refresh token, primary refresh token (PRT)

  #>