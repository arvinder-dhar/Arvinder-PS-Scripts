<#
Author : Arvinder
Description :  The function will get the Expiration and Registration dates of the client secrets in Azure AD
Dependency : "AzureAD" module and AAD user (On-prem Synced or cloud) which will be used for authentication
Version : 1
#>

## Run this command before executing the Function
# Connect-AzureAD

Function Get-AzureADAppSecretInfo {
    [CmdletBinding()]
    Param(
        #Want to support multiple computers
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [String[]]$ObjectId
    )
    
 Begin{}

 Process{

foreach ($oid in $objectid) {

try {
$data = $null
$data = Get-AzureADApplication -ObjectId $oid | Select-Object *

$extension = $null
$extension = $data | Select-Object -ExpandProperty PasswordCredentials | Select-Object startdate,enddate

for ($i = 0; $i -lt $extension.startdate.Count; $i++)
{ 

  $Prop=[ordered]@{ #With or without [ordered]

                'App Name'=$data.DisplayName;
                'Start Date '=$extension.Startdate[$i];
                'End Date'=$extension.Enddate[$i];
                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
}

}

catch {
Write-Warning "No App Found with Object id : $oid"
}
}
}

End{}

}