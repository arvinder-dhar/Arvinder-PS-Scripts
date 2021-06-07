#Description : SID to User Id

$sid = Read-Host "Enter the SID"
$objSID = New-Object System.Security.Principal.SecurityIdentifier ($sid)
$objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
$objUser.Value

#or 

((New-Object System.Security.Principal.SecurityIdentifier ($sid)).Translate( [System.Security.Principal.NTAccount])).value
