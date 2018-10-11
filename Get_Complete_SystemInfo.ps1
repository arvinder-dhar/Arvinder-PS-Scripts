##Author : Arvinder
##Description : This script will get systeminfo of remote computers that are fetched from a text file
## Version : 2
## New Updates : Earlier Version script used to give all data on one worksheet, now two worksheets are created , one for System info and other for disk report

#Problems To address : Teaming issue from sharique and gyan

#### Start ####

## Install the ImportExcel Module

iex (new-object System.Net.WebClient).DownloadString('https://raw.github.com/dfinke/ImportExcel/master/Install.ps1')

$Report_ServerDetails = $null
$computers = $null

$computers = Get-Content '.\computers.txt'

foreach ($Computer in $computers)
{
 
Try{

#### Creating a table to include all the necessary information ####

     $ServerDetails = "" | Select Server_Name,Server_Type,Domain_Name,IP,Subnet_Mask,Gateway,Primary_DNS,Secondary_DNS,
                                  Operating_system,Operating_system_version,Operating_system_architecture,Hardware_model,
                                  Antivirus,Antivirus_Version,Memory_GB,Processor_count,Processor_speed_Mhz,Processor_name,Bios
                                             
     
Write-Verbose "Working on $Computer" -Verbose

#### Retreival of values are started from here ####

$value = [bool](Get-WmiObject -ComputerName $Computer -Class win32_computersystem -ErrorAction SilentlyContinue | select -Property * | Select-String "Virtual")
if ($value -eq "True")
{
$type = "Virtual"
}

else { $type = "Physical"}


$domain = (Get-WmiObject -ComputerName $Computer -Class win32_computersystem -ErrorAction SilentlyContinue ).Domain
$IP = (Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'"-ErrorAction SilentlyContinue ).IPAddress | Out-String
$subnet = (Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" -ErrorAction SilentlyContinue ).IPSubnet | Out-String
$Gateway = (Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" -ErrorAction SilentlyContinue ).DefaultIPGateway | Out-String
$primary = (Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'" -ErrorAction SilentlyContinue ).DNSServerSearchOrder[0]
$secondary = (Get-WmiObject -ComputerName $Computer -Class Win32_NetworkAdapterConfiguration -Filter "IPEnabled = 'True'").DNSServerSearchOrder[1]
$os= (Get-Wmiobject -ComputerName $Computer -Class Win32_OperatingSystem ).Caption
$os_version = (Get-Wmiobject -ComputerName $Computer -Class Win32_OperatingSystem).CSDVersion
$os_architecture= (Get-Wmiobject -ComputerName $Computer -Class Win32_OperatingSystem).OSArchitecture
$model = (Get-WmiObject -ComputerName $Computer -Class win32_computersystem).model
$av = (Get-WmiObject -ComputerName $Computer -Class win32_product | Where-Object {$_.Name -like "*virus*"}).Caption
$av_version = (Get-WmiObject -ComputerName $Computer -Class win32_product | Where-Object {$_.Name -like "*virus*"}).Version
$ram = (Get-WmiObject -ComputerName $Computer -Class win32_computersystem).TotalPhysicalMemory /1gb -as [int]
$proc = (Get-WmiObject -ComputerName $Computer -Class win32_processor).DeviceID.count
$proc_speed = (Get-WmiObject -ComputerName $Computer -Class win32_processor).MaxClockSpeed[0]

If ( (Get-WmiObject -ComputerName $Computer -Class win32_processor).Name.count -gt 1)
{ $proc_name = (Get-WmiObject -ComputerName $Computer -Class win32_processor).Name[0] }

Else { $proc_name = (Get-WmiObject -ComputerName $Computer -Class win32_processor).Name }

$Bios= (Get-WmiObject -ComputerName $Computer -Class Win32_bios).Caption

#### Fetching information retreived  from above and including the same in the table that was created earlier ####
           
$ServerDetails.Server_Name =$Computer
$ServerDetails.Server_Type =$type
$ServerDetails.Domain_Name = $domain
$ServerDetails.IP = $IP
$ServerDetails.Subnet_Mask = $subnet
$ServerDetails.Gateway = $Gateway
$ServerDetails.Primary_DNS = $primary
$ServerDetails.Secondary_DNS = $secondary
$ServerDetails.Operating_system = $os
$ServerDetails.Operating_system_version = $os_version
$ServerDetails.Operating_system_architecture = $os_architecture
$ServerDetails.Hardware_model =$model
$ServerDetails.Antivirus = $av
$ServerDetails.Antivirus_Version = $av_version
$ServerDetails.Memory_GB = $ram
$ServerDetails.Processor_count = $proc
$ServerDetails.Processor_speed_Mhz = $proc_speed
$ServerDetails.Processor_name = $proc_name
$ServerDetails.Bios = $Bios
 
   [array]$Report_ServerDetails += $ServerDetails  


   }

Catch {

#### Computers that are not reachable for any reason are fetched here ####

Write-Host " "
Write-Warning "$Computer is not accessible"
Write-Host " "  
$ServerDetails.Server_Name =$Computer
$ServerDetails.Server_Type = "Server Not Reachable"
 
[array]$Report_ServerDetails += $ServerDetails  
   
        }

 }

#### First Report is saved on First Worksheet in a excel file #### 
        
$Report_ServerDetails | Export-Excel Final_Report.xlsx -WorkSheetname "Server_Info" -AutoSize

#### Second Report for Disk Info is saved on Second Worksheet ####

$disk_data = $null

foreach ($server in $computers)

{

$remote= [bool](Test-WSMan -ComputerName $server -ErrorAction SilentlyContinue)
$ping = Test-Connection -ComputerName $server -Quiet

 if ($remote -eq "True" -or $ping -eq "True"){

Write-Verbose "Getting Disk info for $server" -Verbose

$data = Get-WmiObject -ComputerName $server -class Win32_logicalDisk -ErrorAction SilentlyContinue | Where-Object {$_.DriveType -eq '3'} |
Select @{n='Server_Name';e={$_.PSComputerName}}, 
        @{n='Disk Name';e={$_.DeviceID}},
         @{n='Total Size(GB)';e={[math]::Round(($_.Size)/1GB,1)}},
          @{n='Free Space(GB)';e={[math]::Round(($_.Freespace)/1GB,1)}} -OutVariable data

[array]$disk_data += $data
          
$disk_data | Export-Excel Final_Report.xlsx -WorkSheetname "Disk_Info" -AutoSize

}
  
else

{

write-host ""
write-warning "No disk info found for $server"
Write-Host ""

}

}

#### End ####