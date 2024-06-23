<#
.Synopsis
   This Function will display general info of computer(s)
.DESCRIPTION
   This Function will display detailed general info of computer(s) 
   like RAM,Processor,OS and several others
.EXAMPLE
   Getting information for the local computer
   Get-SystemInfo -ComputerName localhost
.EXAMPLE
   Getting information for remote computers
   Get-SystemInfo -ComputerName comp1, comp2
 .EXAMPLE
   Getting information for remote computers fetched from a text file
   Get-Content c:\servers.txt | Get-SystemInfo
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   Function written by Arvinder
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>

Function Get-SystemInfo {
    [CmdletBinding()]
    Param(
        #Want to support multiple computers
        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true)]
        [String[]]$ComputerName
    )
    
 Begin{}
 Process{

 foreach($Computer in $ComputerName){

    $remote= [bool](Test-WSMan -ComputerName $Computer -ErrorAction SilentlyContinue)
    $ping = Test-Connection -ComputerName $Computer -Quiet

 if ($remote -eq "True" -and $ping -eq "True") {

    
$value = [bool](Get-WmiObject -ComputerName $Computer -Class win32_computersystem -ErrorAction SilentlyContinue | Select-Object -Property * | Select-String "Virtual")
    if ($value -eq "True"){ $type = "Virtual" }

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

        $Prop=[ordered]@{ #With or without [ordered]

                'Computer Name'=$computer;
                'Computer Type' =$type
                'Domain Name' = $domain
                'IP' = $IP
                'Subnet Mask' = $subnet
                'Gateway' = $Gateway
                'Primary DNS' = $primary
                'Secondary DNS' = $secondary
                'OS' = $os
                'OS Version' = $os_version
                'OS Architecture' = $os_architecture
                'Hardware model' =$model
                'Antivirus' = $av
                'Antivirus Version' = $av_version
                'Memory(GB)' = $ram
                'Processor count' = $proc
                'Processor speed(Mhz)' = $proc_speed
                'Processor name' = $proc_name
                'Bios' = $Bios

                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
        }

else {
            
        $Prop=[ordered]@{ #With or without [ordered]

                'Computer Name'=$computer;
                'Computer Type' ="Computer Not Reachable";
                'Domain Name' = ""
                'IP' = ""
                'Subnet Mask' = ""
                'Gateway' = ""
                'Primary DNS' = ""
                'Secondary DNS' = ""
                'OS' = ""
                'OS Version' = ""
                'OS Architecture' = ""
                'Hardware model' = ""
                'Antivirus' = ""
                'Antivirus Version' = ""
                'Memory(GB)' = ""
                'Processor count' = ""
                'Processor speed(Mhz)' = ""
                'Processor name' = ""
                'Bios' = ""
              
                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
        }

        }
   }

 End{}

}