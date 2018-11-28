<#
.Synopsis
   This Function will display Last Patched Date of computer(s)
.DESCRIPTION
   This Function will display Last Patched Date of computer and
   Will calculate the days based on that date
.EXAMPLE
   Getting information for the local computer
   Get-PatchDate -ComputerName localhost
.EXAMPLE
   Getting information for remote computers
   Get-PatchDate -ComputerName comp1, comp2
 .EXAMPLE
   Getting information for remote computers fetched from a text file
   Get-Content c:\servers.txt | Get-PatchDate
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

Function Get-PatchDate {
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

       $patchdate = (Get-WmiObject -Class win32_quickfixengineering -ComputerName $Computer -ErrorAction SilentlyContinue | 
       sort InstalledOn -Descending | select -First 1).InstalledOn

       $EndDate =  Get-Date
       
       $patch_days =  (New-TimeSpan -Start $patchdate -End $EndDate).days

        $Prop=[ordered]@{ #With or without [ordered]
                'Computer Name'=$computer;
                'Last Patch Date '=$patchdate;
                'Patch Days'=$patch_days;
                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
        }

else {
            
        $Prop=[ordered]@{ #With or without [ordered]
                'Computer Name'=$computer;
                'Last Patch Date '="Computer Not Reachable";
                'Patch Days'="NA";
                }

        $Obj=New-Object -TypeName PSObject -Property $Prop 
        Write-Output $Obj
        }

        }
   }

 End{}

}