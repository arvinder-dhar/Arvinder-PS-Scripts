## Gets the Azure Resource Manager Module (If available or not)

Get-Module -ListAvailable AzureRM

## Installing items from the PowerShell Gallery requires the PowerShellGet module
## See if you have PowerShellGet installed on your system (By Default Version 5 contains it)

$Check = [Bool](Get-Module PowerShellGet -list | Select-Object Name,Version,Path)

If ( $Check = $true)
{

## Install the Azure Resource Manager modules from the PowerShell Gallery
## Choose Yes to All when prompted
Install-Module AzureRM -AllowClobber 

## Load the Azure RM Module
Import-Module AzureRM

## Checking the Module name and version of Azure RM in PowerShell

$Azure_Module=(Get-Module AzureRM -list).Name
$Version = (Get-Module AzureRM -list).Version
"Module Installed : $Azure_Module"
"Module Version : $Version"

}

Else { Write-Warning " Azure Module cann't be imported due to unavailablity of PowerShellGet module`
Please upgrade your PS to version 5 and above" }


## Create connection with azure, enter creds when prompted

Login-AzureRmAccount

############################################################

Get-AzureRmResourceGroup

$subnetid = (Get-AzureRmVirtualNetwork -ResourceGroupName arvinder-rg).Subnets[0].Id

$pip = New-AzureRmPublicIpAddress -ResourceGroupName arvinder-rg -Location CentralIndia `
        -AllocationMethod Static -IdleTimeoutInMinutes 4 -Name "10.0.0.18"
$PublicIpAddressId = $pip.id

$nsgid = (Get-AzureRmNetworkSecurityGroup -ResourceGroupName arvinder-rg).Id

$nic = New-AzureRmNetworkInterface -Name Powershellnic -ResourceGroupName arvinder-rg -Location CentralIndia `
    -SubnetId $subnetid -PublicIpAddressId $PublicIpAddressId -NetworkSecurityGroupId $nsgid

# Define a credential object
$cred = Get-Credential

# Create a virtual machine configuration
$vmConfig = New-AzureRmVMConfig -VMName PowershellVM -VMSize "Standard_A1" | `
    Set-AzureRmVMOperatingSystem -Windows -ComputerName PowershellVM -Credential $cred | `
    Set-AzureRmVMSourceImage -PublisherName MicrosoftWindowsServer -Offer WindowsServer `
    -Skus 2016-Datacenter -Version latest | Add-AzureRmVMNetworkInterface -Id $nic.Id

New-AzureRmVM -ResourceGroupName arvinder-rg -Location CentralIndia -VM $vmConfig

