######Start######

<# Author: Arvinder
  Short Description : This Script will retrieve the AD Objects added to the DFS Path and retreive the basic information like
                      1. Description
                      2. Owner(s)
                      3. Members (in case of Group Objects)
  Improvements :
                    1. Prompt for DFS Path Confirmation
                    2. Excluded Domain Admins groups from the Report 
                    3. Group Members report in separate Workbook
  Version : 2.0
#>

#################################################
############### PART 1 START ####################
#################################################

## Directory Creation & Switching to it
$date = Get-Date -Format MMMM-dd-yyyy
if (!(Test-Path C:\Temp\dfs-permissions-$date)) {New-Item C:\Temp\DFS-Permissions-$date -ItemType Directory | Out-Null
Write-Host ""
Write-Host "*************************************************************" -ForegroundColor Green
Write-Host " Folder => DFS-Permissions-$date created under C:\Temp" -ForegroundColor Cyan
Write-Host "*************************************************************" -ForegroundColor Green
Write-Host ""
}

Set-Location C:\Temp\DFS-Permissions-$date

## File Containing DFS Paths, Break if not found
$dfs_paths = Get-Content C:\Users\$env:username\desktop\DFS.txt -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Report will be pulled for Below DFS paths and subsequent Child Folders" -ForegroundColor DarkMagenta
Write-Host ($dfs_paths | out-string) -ForegroundColor Green
Write-Host "Do you want to Proceed (Y/N) ?" -ForegroundColor Cyan
$Proceed_confirmation = Read-Host 
if ($Proceed_confirmation -like 'N') {Break}

elseif ($Proceed_confirmation -like 'Y') {
    
Write-Host "Phase 1 Started"
if ([bool]$dfs_paths -eq $false) {
Write-Warning "DFS.txt file not found in Path => C:\Users\$env:username\Desktop"
Break
}

## Master Variable
$output = @()

foreach ($dfs_path in $dfs_paths) {

$paths = $null

$paths = (Get-ChildItem -Path $dfs_path -Directory -Recurse -Depth 1 | Select-Object FullName).FullName | Get-Unique
$paths = $paths + $dfs_path

foreach ($path in $paths) {

## Test if the path exists
$test_path = Test-Path $path 

if ($test_path -eq $true) {

$domain_values = @()
$sid_values = @()
$converted_values = @()
$acl_values = @()

[array]$domain_values += (get-acl $path | Select-Object path -ExpandProperty access `
| Where-Object {$_.IdentityReference -like "Domain1*" -or $_.IdentityReference -like "Domain2*" -or $_.IdentityReference -like "Domain3*"}).IdentityReference.value

[array]$sid_values += (get-acl $path | Select-Object path -ExpandProperty access | Where-Object {$_.IdentityReference -like "S-1*"}).IdentityReference.value

foreach ($sid in $sid_values) {

try{

#### Checks and Converts the SID's if they are not orphan

$converted_value = $null
$converted_value = ((New-Object System.Security.Principal.SecurityIdentifier ($sid)).Translate( [System.Security.Principal.NTAccount])).value 
[array]$converted_values += $converted_value

}

catch {#Write-Warning "Can't Convert $sid"}

}

$acl_values = $domain_values + $converted_values | Get-Unique
$acl_values = $acl_values -notlike "*Domain Admins*"

foreach ($acl_value in $acl_values){

$Properties = [ordered]@{

'Folder Path'=$path;
'Group'=$acl_value}

[array]$output += New-Object -TypeName PSObject -Property $Properties

}

Write-Host ""
Write-Host "Working on Object ==> $acl_value found in path ==> $path" -ForegroundColor Green
Write-Host ""

}

}

if ($test_path -eq $false) {
Write-Warning "Can't Access $test_path, Please check access"
}

}

}

$output = $output  | Sort-Object 'Folder Path',Group -Unique

#################################################
############### PART 1 END ######################
#################################################


#################################################
############### PART 2 START ####################
#################################################
Write-Host ""
Write-Host "Phase 2 Started" -Verbose
Write-Host ""

Import-Module ActiveDirectory
if (!(Get-Module ActiveDirectory)) {
  Write-Warning "ActiveDirectory Module not loaded, Please check !!"
  Break }

$report = @()
$final_report = @()

foreach ($value in $output) {

$report = "" | Select-Object Path,Object_Domain,Object_Name,Object_Category,Primary_Owner,Secondary_Owner,Description,Notes,Members

$domain = $value.Group.Split('\')[0]
$object = $value.Group.Split('\')[1]
$data = Get-ADObject -LDAPFilter "(cn=$object)" -Properties info,Description,Primary_owner_attribute,Secondary_Owner_Attribute -Server $domain

$report.Path = $value.'Folder Path'
$report.Object_Domain = $domain
$report.Object_Name = $object
$report.Object_Category = $data.ObjectClass
$report.Primary_Owner = $data.Primary_Owner_Attribute #change as per attriute defined in AD
$secondary_Owner = $data.Secondary_Owner_Attribute | Out-String #change as per attriute defined in AD
$report.Secondary_Owner = $secondary_Owner.Trim()
$report.Description = $data.Description
$report.Notes = $data.info
$report.Description = $group_info.Description

if ($data.ObjectClass -like "User"){$report.Members = "NA"}

if ($data.ObjectClass -like "Group"){

    $members = (Get-ADGroupMember $object -Server $domain).name
    if ($members.count -gt 10) {$report.Members = "Count >10, Refer Members Report"}
    else {$report.Members = $members -join "," | Out-String}

}
$location = $report.Path
$location_group = $value.Group
Write-Host ""
Write-Host "Data Extraction Complete for Path ==> $location`nGroup ==> $location_group" -ForegroundColor Green
Write-Host ""

$final_report += $report
}

$time = get-date -Format "MMMM-dd-yyyy-HH-mm"

#Get ACL Permissions Details
$final_report | Export-Csv C:\Temp\DFS-Permissions-$date\DFS-Permissions-$time.csv -NoTypeInformation

#Get Group Members Details
$groups = $final_report | Where-Object {$_.object_category -like "group" -and $_.members -like "Count*"}`
  | Select-Object object_name,object_domain | sort-object object_name -Unique

foreach ($group in $groups) {
$group_name = $null
$group_domain = $null

$group_name = $group.Object_Name
$group_domain = $group.Object_Domain
[array]$group_members +=  Get-ADGroupMember $group_name -Server $group_domain | Select-Object @{n='Group Name';e={$group_name}},name,SamAccountName,distinguishedName
}

$group_members | Export-Csv C:\Temp\DFS-Permissions-$date\Members-$time.csv -NoTypeInformation

Write-Host ""
Write-Host "Reports Extraction Complete" -ForegroundColor DarkMagenta
Write-Host "DFS Permissions Report : DFS-Permissions-$time.csv" -ForegroundColor Cyan
Write-Host "Members Report : Members-$time.csv" -ForegroundColor Cyan
Write-Host ""
}

else {Write-Warning "Incorrect Selection !!`nType either Y or N"} 

#################################################
############### PART 2 END ######################
#################################################

######End######
