<#
.Synopsis
   This Function will display attached Disks to the computer(s)
.DESCRIPTION
   This Function will display only the system attached drives fetched from Disk Management and
   not any mapped drives
.EXAMPLE
   Getting information for the local computer
   Get-DiskInfo -ComputerName localhost
.EXAMPLE
   Getting information for remote computers
   Get-DiskInfo -ComputerName comp1, comp2
 .EXAMPLE
   Getting information for remote computers fetched from a text file
   Get-Content c:\servers.txt | Get-DiskInfo
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

Function Get-DiskInfo {
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

 if ($remote -eq "True" -or $ping -eq "True")
 
    {

$data = Get-WmiObject -ComputerName $Computer -class Win32_logicalDisk -ErrorAction SilentlyContinue | Where-Object {$_.DriveType -eq '3'} |
Select @{n='Computer Name';e={$_.PSComputerName}}, 
        @{n='Disk Name';e={$_.DeviceID}},
         @{n='Total Size(GB)';e={[math]::Round(($_.Size)/1GB,1)}},
          @{n='Free Space(GB)';e={[math]::Round(($_.Freespace)/1GB,1)}} -OutVariable data
          
$data

}
  
else { 

$Prop=[ordered]@{ #With or without [ordered]
                'Computer Name'=$computer;
                'Disk Name'="Computer Not Reachable";
                'Total Size(GB)'="NA";
                'Free Space(GB)' = "NA"

                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj 
        
        }

        }
   }

 End{}

}