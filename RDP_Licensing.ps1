## Description : Script will configure RDP license for servers in servers.txt file

$servers = Get-Content C:\Users\env:username\desktop\servers.txt

foreach ($server in $servers) {

Invoke-Command -ComputerName $server -ScriptBlock {

Import-Module servermanager

if ( $server -like "xyz" ) {
    $serverArray  = @("abc.com","def.com") # RDP licensing server names
} 

else {
    $serverArray = @("123.com","456.com") # RDP licensing server names
}

$obj = Get-WmiObject -ComputerName $server -namespace "Root/CIMV2/TerminalServices" Win32_TerminalServiceSetting
$obj.ChangeMode(4)
$obj = Get-WmiObject -ComputerName $server -namespace "Root/CIMV2/TerminalServices" Win32_TerminalServiceSetting

$obj.SetSpecifiedLicenseServerList($serverArray)

Write-Verbose "Licensing complete for $server" -Verbose

}

}