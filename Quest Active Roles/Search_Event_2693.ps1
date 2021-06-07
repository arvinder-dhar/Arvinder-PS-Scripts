<#
Author : Arvinder
Description : Search for 2693 event id under all 5 ARS servers and generate corresponding CSV to it
        Current ARS Servers are : 'ars1','ars2','ars3','ars4','ars5'
        Time Duration : 2 Days from current date

Pre-Requisites : Script can be run from Account that has local Admin rights on the ARS boxes
                 DS team member can use there DMN1\SAxxxxx to run this
                 
                 IMPORTANT : Run on box that has WINRM connectivity to the ARS boxes, 
                 If run from one of the ARS boxes it will generate the report for other 4 but might fail for the one it's running on...

Ref URL's :
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.diagnostics/get-winevent?view=powershell-7
https://devblogs.microsoft.com/scripting/how-to-improve-the-performance-of-a-powershell-event-log-query/
https://4sysops.com/archives/fast-event-log-search-in-powershell-with-the-filterhashtable-parameter/
https://itfordummies.net/2018/07/30/get-eventlog-event-details-content-powershell/
https://community.spiceworks.com/how_to/2776-powershell-sid-to-user-and-user-to-sid
https://powershell.org/forums/topic/invoke-command-remove-pscomputername/
#>

#####START#####

cd C:\Users\$env:username\desktop #Change Directory to current Logged in User

Invoke-Command -ComputerName ars1,ars2,ars3,ars4,ars5 -ScriptBlock {

Get-WinEvent -FilterHashtable @{
ProviderName= "ARAdminSvc”;
LogName = “ARAdminService”;
Id = "2693";
StartTime = ([datetime]::today).AddDays(-2)} |

ForEach-Object -Process {New-Object -TypeName PSObject -Property @{
'ARS Server' = $_.MachineName;
'ID'=$_.Id;
'User' = ((New-Object System.Security.Principal.SecurityIdentifier ($_.UserId)).Translate( [System.Security.Principal.NTAccount])).value;
'Source' = $_.ProviderName;
'Log Time'=$_.TimeCreated;
'Message'=$_.properties[2].value

} 

}


} | Select-Object -Property * -ExcludeProperty PSComputerName,RunspaceID,PSShowComputerName | Export-Csv ARS_Logs.csv -NoTypeInformation # Csv file exported to current logged in user

#####END#####
