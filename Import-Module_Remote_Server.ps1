## Imports module from remote computer
## if there is any issue, run the commands individually

$session = New-PSSession server1

Invoke-Command -ScriptBlock {Import-Module activedirectory } -Session $session

Import-PSSession -module ActiveDirectory -session $session


#########################################################################

## Another Way (Not tested yet)

$session = New-PSSession -ComputerName Server1

Import-Module -PSSession $s -Name NetSecurity
    
Get-Command -Module NetSecurity -Name Get-*Firewall* # to check if module has been imported in the current session

