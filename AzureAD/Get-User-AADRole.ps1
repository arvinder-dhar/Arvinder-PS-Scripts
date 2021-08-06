<#
Author : Arvinder
Description : The Script will Get the Azure AD Roles of an On-Prem User Fectched From CSV
Dependencies : "AzureADPreview" Module

#>

Connect-AzureAD #Furnish Creds interactively

#Define Null Array variables
$users = $null
$report = @()
$final_report = @()

#Get User information Preferrably in SAM Account Name Format
$users = Import-Csv .\Users.csv


foreach ($user in $users.Account) {
    $check = [bool](Get-AzureADUser -SearchString $user)
        if ($check -eq $true) {

            $report = "" | Select-Object User,UPN,ObjectId,AAD_Roles,AssignmentState

            $data = $null
            $data = Get-AzureADUser -SearchString $user
            $objectid = $data.ObjectId

            $report.User = $data.DisplayName
            $report.UPN = $data.UserPrincipalName
            $report.ObjectId = $objectid


            $role_data = Get-AzureADMSPrivilegedRoleAssignment -ProviderId "aadRoles" `
            -ResourceId "<Tenant-Id>" -Filter "subjectId eq '$objectid'"

            $roledefids = $role_data.RoleDefinitionId

            foreach ($roledefid in $roledefids) {
            $report.AAD_Roles += ((Get-AzureADDirectoryRoleTemplate | `
            Where-Object {$_.objectid -like $roledefid}).Displayname) -join "," | Out-String
            }

            $report.AssignmentState = ($role_data.AssignmentState | Out-String)

            $report
            $final_report += $report

}

        elseif ($check -eq $false) {
    

            write-warning "$user not found in AAD"
            $report = "" | Select-Object User,UPN,ObjectId,AAD_Roles,AssignmentState
            $report.user = $user
            $report.UPN = "User not found in AAD"
            $report.ObjectId = "NA"
            $report.AAD_Roles = "NA"
            $report.AssignmentState = "NA"

            $final_report += $report
            
}

}

$final_report | Export-Csv c:\users\$env:username\desktop\User-AAD-Roles.csv -NoTypeInformation