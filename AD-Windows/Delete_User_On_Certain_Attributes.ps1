## Author: Arvinder Dhar
## Requirements: Powershell V3.0 is required at least or else script might fail
## Run the Script with elevated privileages (Run as administrator)
## Data will be read from "DeleteAccounts.csv" placed in C:\adextensions with headers named "abc" and "xyz", if any info is missing or different the script will fail
## There will be a pop-up to change the execution policy, choose YES for that

############################ Start ######################################

#Sets Execution Policy to Remotesigned (Choose YES when prompted)
Set-ExecutionPolicy RemoteSigned
 
#Switches to Directory "adextensions"
cd C:\adextensions

#Imports data from csv to "data" variable
$Data = Import-Csv '.\DeleteAccounts.csv'

##Loop begins for each row in the csv file
foreach ($user in $Data) {

$abc = $user.abc
$xyz = $user.xyz

## "check_abc" and "check_xyz" variables created to check if user exsists with the mentioned abc and xyz as per the csv file
$check_abc = [bool](Get-ADUser -Filter 'abcId -eq $abc')
$check_xyz = [bool](Get-ADUser -Filter 'xyzID -eq $xyz')

if ($check_abc -eq $true -or $check_xyz -eq $true )

{

$sam = (Get-ADUser -Filter {abcId -like $abc -and xyzID -eq $xyz } -Properties *).SamAccountName
$name = (Get-ADUser -Identity $sam -Properties *).DisplayName

write-host "User $name($sam) with abc_Id:$abc and xyz_Id:$xyz Deleted" -ForegroundColor Green

Remove-ADUser -Identity $sam -Confirm:$false

}

else

{

Write-Warning  "No User with abc_Id:$abc and xyz_Id:$xyz Found in AD Database"

}

}

############################ End ######################################