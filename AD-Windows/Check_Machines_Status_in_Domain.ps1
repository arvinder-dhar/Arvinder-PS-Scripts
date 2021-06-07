#Author : Arvinder
#Description : checks if the machine is availabe in the domain or not based on the csv file fetched as input source
#limitations : script cannot fetch the machine info until domain name is mentioned against the machine column

###### START  #####

$servers = $null
$result = @()
$final_result = @()

$servers = Import-Csv "C:\Users\$env:username\Desktop\Machines.csv"

foreach ($server in $servers){

$computer = $server.Device
$domain = $server.domain

try {

$result = "" | Select-Object Device,Domain,Machine_in_Domain,Enabled

$value = (Get-ADComputer -Identity $computer -Server $domain -Properties * -ErrorAction SilentlyContinue)
$result.Device = $value.Name
$result.Domain = $domain
$result.Machine_in_Domain = "Present"
$result.Enabled = $value.Enabled

$result
[array]$final_result += $result
 
}

catch {

$result = "" | Select-Object Device,Domain,Machine_in_Domain,Enabled

$result.Device = $computer
$result.Domain = $domain
$result.Machine_in_Domain = "Absent"
$result.Enabled = "Not Applicable"

$result
[array]$final_result += $result

}

}

$final_result | Export-Csv C:\Users\$env:username\Desktop\report.csv -NoTypeInformation

###### END #####
