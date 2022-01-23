### All have to be separate including Curl, https, powershell with due testing completed only

##ROPC

$ClientID = ""
$loginURL = "https://login.microsoftonline.com"
$tenantid = ""
$scope = "https://graph.microsoft.com/.default"
 
$body = @{
    grant_type="password";
    scope=$scope;
    client_id=$ClientID;
    username = "";
    password = ""
}

$token = Invoke-RestMethod -Method Post -Uri $("$loginURL/$tenantid/oauth2/v2.0/token") -Body $body

$DataUrl = "https://graph.microsoft.com/v1.0/users/user-upn" ## for delegated, the account should have access too,, test below scenarios & update accordingly
###1. App has user.read all application permission <or>
###2. App has user.read.all delegated permission
###3. only user has user admin role in AAD

$data = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($token.access_token)"} -Uri $DataUrl -Method Get).value


#### Curl Method (test this including scenarios part)
### Add HTTPS as well
https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth-ropc

## Client-credentials

$ClientID = ""
$ClientSecret = ""
$loginURL       = "https://login.microsoftonline.com"
$tenantid   = ""
$scope = "https://graph.microsoft.com/.default"
 
$body = @{
    grant_type="client_credentials";
    scope=$scope;
    client_id=$ClientID;
    client_secret=$ClientSecret
}


$token = Invoke-RestMethod -Method Post -Uri $("$loginURL/$tenantid/oauth2/v2.0/token") -Body $body

$DataUrl = "https://graph.microsoft.com/v1.0/users/upn"

$data = (Invoke-RestMethod -Headers @{Authorization = "Bearer $($token.access_token)"} -Uri $DataUrl -Method Get).value

## Just two scenario and update here then : Client with user.read.all (app permission) with and without

## CURL
### Add HTTPS as well
https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-client-creds-grant-flow


#### Include case of refresh token as well ---> do research and update

########
Include below as well with little explanation of use case,,, limitations and advantages
  1. Implicit grant flow
  2.  auth code grant
  3. on-behalf of flow
  4. device code flow
  5. SAML Bearer Assertion flow (Used by other folks,, heavy testing to be involved,... in absence of lab, incorporate Corporate lab and deduce results)
    https://docs.microsoft.com/en-us/azure/active-directory/develop/v2-saml-bearer-assertion
    
  ## Have some documentation links for access token, id token, refresh token, primary refresh token (PRT)

