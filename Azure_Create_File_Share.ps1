# Create a storage context to authenticate 
$rgName = "***"
$storageAccountName = "arvinderstorage"
$storageKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $rgName -Name $storageAccountName).Value[0]
$storageContext = New-AzureStorageContext $storageAccountName $storageKey
# Create a new storage share 
$shareName = "psshare"
$share = New-AzureStorageShare $shareName -Context $storageContext
