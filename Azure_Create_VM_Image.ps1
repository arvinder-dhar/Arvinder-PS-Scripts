## Description : Create an image of Azure VM using Powershell
## Ref URL : https://docs.microsoft.com/en-us/azure/virtual-machines/windows/capture-image-resource

## Login to Azure Account
Login-AzureRmAccount

## Create some variables
$vmName = "arvindervm"
$rgName = "***"
$location = "centralus"
$imageName = "arvinderimage"

## Make sure the VM has been deallocated
Stop-AzureRmVM -ResourceGroupName $rgName -Name $vmName -Force

## Set the status of the virtual machine to Generalized
Set-AzureRmVm -ResourceGroupName $rgName -Name $vmName -Generalized

## Get the virtual machine
$vm = Get-AzureRmVM -Name $vmName -ResourceGroupName $rgName

## Create the image configuration
$image = New-AzureRmImageConfig -Location $location -SourceVirtualMachineId $vm.ID

## Create the image
New-AzureRmImage -Image $image -ImageName $imageName -ResourceGroupName $rgName
