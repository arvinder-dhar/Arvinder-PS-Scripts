#Connect-AzureAD

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

$report  =  "" | select Displayname,Startdate,Enddate

try {
$data = $null
$data = Get-AzureADApplication -ObjectId $oid | select *

$extension = $null
$extension = $data | select -ExpandProperty PasswordCredentials | select startdate,enddate

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
