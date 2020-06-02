<#
.Synopsis
   This Function will track users that are active in dual or triple domains
.DESCRIPTION
   This Function will track users that are active in dual or triple domains by connecting directly to the 3 Domains
.EXAMPLE
   Get information of all active dual or triple domain accounts in 3 domains
   Get-DuplicateAccounts
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Function written by Arvinder
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

Function Get-DuplicateAccounts {
    [CmdletBinding()]
    Param(
        #Want to support multiple computers
        [Parameter(Mandatory=$false,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [String[]]$Domain
    )

Begin{}
Process{

$domain1_users = (Get-ADUser -Filter 'name -like "*"' -Server domain1 | Where-Object {$_.samaccountname -like "a*" -and $_.enabled -eq $true} ).samaccountname
$domain2_users = (Get-ADUser -Filter 'name -like "*"' -server domain2 | Where-Object {$_.samaccountname -like "a*" -and $_.enabled -eq $true}).samaccountname
$domain3_users = (Get-ADUser -Filter 'name -like "*"' -server domain3 | Where-Object {$_.samaccountname -like "a*" -and $_.enabled -eq $true}).samaccountname

$domain1_domain2 = Compare-Object -ReferenceObject $domain1 -DifferenceObject $domain2 -IncludeEqual -ExcludeDifferent -PassThru
$domain2_domain3 = Compare-Object -ReferenceObject $domain2 -DifferenceObject $domain3 -ExcludeDifferent -IncludeEqual -PassThru
$domain3_domain1 = Compare-Object -ReferenceObject $domain3 -DifferenceObject $domain1 -ExcludeDifferent -IncludeEqual -PassThru

$users = $domain1_domain2 + $domain2_domain3 + $domain3_domain1 | Select-Object -Unique

foreach ($user in $users) {

$domain1_check = $null
$domain2_check = $null
$domain3_check = $null

$domain1_data = $null
$domain2_data = $null
$domain3_data = $null

$domain1_check = [bool](Get-ADUser -Identity $user -Server domain1)
$domain2_check = [bool](Get-ADUser -Filter {samaccountname -like $user} -Server domain2 )
$domain3_check = [bool](Get-ADUser -Filter {samaccountname -like $user} -server domain3 )

$domain1_data = Get-ADUser -Identity $user -Properties * -Server domain1
$domain2_data = Get-ADUser -Filter {samaccountname -like $user} -Server domain2 -Properties *
$domain3_data = Get-ADUser -Filter {samaccountname -like $user} -server domain3 -Properties *

$xyz_attribute = (Get-ADUser -Identity $user -Properties *).xyz_attribute -join ','

if ($domain1_check -eq $true -and $domain2_check -eq $true -and $domain3_check -eq $true) {
$property = [ordered] @{
 'User ID' = $user ;
 'Designation' = $domain1_data.Title ;
 'Domain1 Enabled' = $domain1_data.enabled ;
 'Domain1 Last Login' = if ($domain1_data.enabled -eq $true) {$domain1_data.LastLogonDate} else {"NA"} ;
 'Domain2 Present' = "Present" ;
 'Domain2 Last Login' = $domain2_data.LastLogonDate ;
 'Domain3 Present' = "Present" ;
 'Domain3 Last Login' = $domain3_data.LastLogonDate ;
 'XYZ Attribute' = $xyz_attribute ;
}
}

elseif ($domain1_check -eq $true -and $domain2_check -eq $true ) {
$property = [ordered] @{
 'User ID' = $user ;
 'Designation' = $domain1_data.Title ;
 'Domain1 Enabled' = $domain1_data.enabled ;
 'Domain1 Last Login' = $domain1_data.LastLogonDate ;
 'Domain2 Present' = "Present" ;
 'Domain2 Last Login' = $domain2_data.LastLogonDate ;
 'Domain3 Present' = "Not Present" ;
 'Domain3 Last Login' = "NA" ;
 'XYZ Attribute' = $xyz_attribute ;
   }
   }

elseif ($domain1_check -eq $true -and $domain3_check -eq $true) {
$property = [ordered] @{
 'User ID' = $user ;
 'Designation' = $domain1_data.Title ;
 'Domain1 Enabled' = $domain1_data.enabled ;
 'Domain1 Last Login' = $domain1_data.LastLogonDate ;
 'Domain2 Present' = "Not Present" ;
 'Domain2 Last Login' = "NA" ;
 'Domain3 Present' = "Present" ;
 'Domain3 Last Login' = $domain3_data.LastLogonDate ;
 'XYZ Attribute' = $xyz_attribute ;
      }
      }

$Object = New-Object -TypeName PSObject -Property $property
Write-Output $Object

}

}

End{}

}
