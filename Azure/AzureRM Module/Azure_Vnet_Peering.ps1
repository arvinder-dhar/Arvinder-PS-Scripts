# Description : Peer two vnets named "arvinder-vnet" and "ruchi-vnet"

# Load arvinder-vnet and ruchi-vnet into Variables
$vneta = Get-AzureRmVirtualNetwork -Name "arvinder-vnet" -ResourceGroupName "arvinderrg"
$vnetb = Get-AzureRmVirtualNetwork -Name "ruchi-vnet" -ResourceGroupName "ruchirg"

# Peer arvinder-vnet to ruchi-vnet
Add-AzureRmVirtualNetworkPeering -Name 'Arvinder-Ruchi' -VirtualNetwork $vneta -RemoteVirtualNetworkId $vnetb.Id

# Peer VNETB to VNETA
Add-AzureRmVirtualNetworkPeering -Name 'Ruchi-Arvinder' -VirtualNetwork $vnetb -RemoteVirtualNetworkId $vneta.Id

#Check on the Peering Status  
Get-AzureRmVirtualNetworkPeering -ResourceGroupName Arvinderrg -VirtualNetworkName "arvinder-vnet" | Format-Table VirtualNetworkName, Name, PeeringState