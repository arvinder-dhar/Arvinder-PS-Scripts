## Imports module from remote computer
## if there is any issue, run the commands individually

$session = New-PSSession server1

Invoke-Command -ScriptBlock {Import-Module activedirectory } -Session $session

Import-PSSession -module ActiveDirectory -session $session