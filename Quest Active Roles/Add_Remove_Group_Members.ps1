<#

AUTHOR : Arvinder

DESCRIPTION : Script will Read Members for below groups as per options selected 
              It can also Add and Remove members fetched from files domain1_users.txt & domain2_users.txt saved under c:\temp location

Domain1:
domain1_group1
domain1_group2

Domain2:
domain2_group1
domain2_group2


INSTRUCTIONS :

To Perform Add or Remove operations on domain1 & domain2 Groups , create and save below files respectively as per domain
domain1 : domain1_users.txt
domain2 : domain2_users.txt

Both these files should be saved in location c:\temp
Value in the files should only contain SAMAccoutname a.k.a login name e.g. ,a630219

If there are any other values in the file, the script execution will fail

#>

#####START#####

cd C:\Temp #Change to the location where files are stored

write-Host "Choose the number for the respective domain" -ForegroundColor Green
Write-Host "1 = Domain1 `n2 = Domain2" -ForegroundColor Green
Write-Host ""

$Domain_Selection = Read-Host 
Write-Host ""

#####Domain1#####

 if ($Domain_Selection -eq 1) {Write-Host "You have choosen Domain1" -ForegroundColor Cyan

 Connect-QADService -Service "domain1.xyz:389"
 Write-Host ""

 Write-Host "Make the group Selection" -ForegroundColor Green
 Write-Host "3 = domain1_group1`n4 = domain1_group2" -ForegroundColor Green
 $domain1_group_selection = Read-Host

 if ($domain1_group_selection -eq 3) {Write-Host "You have choosen domain1_group1" -ForegroundColor Cyan
 Write-Host ""
 Write-Host "Operation Required ? Choose below values" -ForegroundColor Green
 Write-Host "" 
 Write-Host "Read : To view the Accounts`nAdd : To Add the users mentioned in file`nDelete : To Remove the users mentioned in file " -ForegroundColor Cyan
 $domain1_operation_selection = Read-Host

 if ($domain1_operation_selection -like "Read") {Write-Host "You have choosen Read operation" -ForegroundColor Cyan
 Get-QADGroupMember -Proxy -Identity domain1_group1 | select -Property samaccountname,dn | sort samaccountname -Descending | Format-Table -AutoSize -Wrap
 
 }
 elseif ($domain1_operation_selection -like "Add") {Write-Host "You have choosen Add Operation" -ForegroundColor Cyan
 Add-QADGroupMember -Proxy -Identity domain1_group1 -Member (Get-Content C:\Temp\domain1_users.txt) -Verbose

 }
 elseif ($domain1_operation_selection -like "Delete") {Write-Host "You have choosen Remove Operation" -ForegroundColor Cyan
 Remove-QADGroupMember -Proxy -Identity domain1_group1 -Member (Get-Content C:\Temp\domain1_users.txt) -Verbose
 }

 else {Write-Warning "Incorrect Operation Selection !! Choose Read, Add or Delete"}
 
 }

 elseif ($domain1_group_selection -eq 4) {Write-Host "You have choosen domain1_group2" -ForegroundColor Cyan
 
 Write-Host ""
 Write-Host "Operation Required ? Choose below values" -ForegroundColor Green
 Write-Host "" 
 Write-Host "Read : To view the Accounts`nAdd : To Add the users mentioned in file`nDelete : To Remove the users mentioned in file " -ForegroundColor Cyan
 $domain1_operation_selection = Read-Host

 if ($domain1_operation_selection -like "Read") {Write-Host "You have choosen Read operation" -ForegroundColor cyan
 Get-QADGroupMember -Proxy -Identity domain1_group2 | select -Property samaccountname,dn | sort samaccountname -Descending | Format-Table -AutoSize -Wrap 
 
 }
 elseif ($domain1_operation_selection -like "Add") {Write-Host "You have choosen Add Operation" -ForegroundColor Cyan
 Add-QADGroupMember -Proxy -Identity domain1_group2 -Member (Get-Content C:\Temp\domain1_users.txt) -Verbose 

 }
 elseif ($domain1_operation_selection -like "Delete") {Write-Host "You have choosen Remove Operation" -ForegroundColor Cyan
 Remove-QADGroupMember -Proxy -Identity domain1_group2 -Member (Get-Content C:\Temp\domain1_users.txt) -Verbose
 }

 else {Write-Warning "Incorrect Operation Selection !! Choose Read, Add or Delete"}
 } # change the group name

 else {Write-Warning "Incorrect Group Selection !! Choose either 3 or 4"}
 
 }

#####Domain2#####

elseif ($Domain_Selection -eq 2) {Write-Host "You have choosen Domain2" -ForegroundColor Cyan

 Connect-QADService -Service "domain2.xyz:389"
 Write-Host ""

 Write-Host "Make the group Selection" -ForegroundColor Green
 Write-Host "5 = domain2_group1`n6 = domain2_group2" -ForegroundColor Green
 $domain2_group_selection = Read-Host

 if ($domain2_group_selection -eq 5) {Write-Host "You have choosen domain2_group1" -ForegroundColor Cyan
 Write-Host ""
 Write-Host "Operation Required ? Choose below values" -ForegroundColor Green
 Write-Host "" 
 Write-Host "Read : To view the Accounts`nAdd : To Add the users mentioned in file`nDelete : To Remove the users mentioned in file " -ForegroundColor Cyan
 $domain2_operation_selection = Read-Host

 if ($domain2_operation_selection -like "Read") {Write-Host "You have choosen Read operation" -ForegroundColor Cyan
 Get-QADGroupMember -Proxy -Identity domain2_group1 | select -Property samaccountname,dn | sort samaccountname -Descending | Format-Table -AutoSize -Wrap
 
 }
 elseif ($domain2_operation_selection -like "Add") {Write-Host "You have choosen Add Operation" -ForegroundColor Cyan
 Add-QADGroupMember -Proxy -Identity domain2_group1 -Member (Get-Content C:\Temp\domain2_users.txt) -Verbose

 }
 elseif ($domain2_operation_selection -like "Delete") {Write-Host "You have choosen Remove Operation" -ForegroundColor Cyan
 Remove-QADGroupMember -Proxy -Identity domain2_group1 -Member (Get-Content C:\Temp\domain2_users.txt) -Verbose
 }

 else {Write-Warning "Incorrect Operation Selection !! Choose Read, Add or Delete"}
 
 } 

 elseif ($domain2_group_selection -eq 6) {Write-Host "You have choosen domain2_group2" -ForegroundColor Cyan
 
  Write-Host ""
 Write-Host "Operation Required ? Choose below values" -ForegroundColor Green
 Write-Host "" 
 Write-Host "Read : To view the Accounts`nAdd : To Add the users mentioned in file`nDelete : To Remove the users mentioned in file " -ForegroundColor Cyan
 $domain2_operation_selection = Read-Host

 if ($domain2_operation_selection -like "Read") {Write-Host "You have choosen Read operation" -ForegroundColor Cyan
 Get-QADGroupMember -Proxy -Identity domain2_group2 | select -Property samaccountname,dn | sort samaccountname -Descending | Format-Table -AutoSize -Wrap
 
 }
 elseif ($domain2_operation_selection -like "Add") {Write-Host "You have choosen Add Operation" -ForegroundColor Cyan
 Add-QADGroupMember -Proxy -Identity domain2_group2 -Member (Get-Content C:\Temp\domain2_users.txt) -Verbose

 }
 elseif ($domain2_operation_selection -like "Delete") {Write-Host "You have choosen Remove Operation" -ForegroundColor Cyan
 Remove-QADGroupMember -Proxy -Identity domain2_group2 -Member (Get-Content C:\Temp\domain2_users.txt) -Verbose
 }

 else {Write-Warning "Incorrect Operation Selection !! Choose Read, Add or Delete"}
 }

 else {Write-Warning "Incorrect Group Selection !! Choose either 5 or 6"}
 
 }

else {Write-Warning "Incorrect Domain Selection !! Choose either 1 or 2"} 

#####END#####
