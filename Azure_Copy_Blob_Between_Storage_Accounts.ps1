# Description : This script will copy Blobs from one storage account to another storage account irrespective of the location

Login-AzureRmAccount

$blobName = "9781509306480_URL_List.pdf"
$sourcecontainer = "arvindercontainer"
$destcontainer = "arvindercontainercopy"
$sourcestorageaccount = "arvinderstorage"
$deststorageaccount = "arvinderstoragecopy"
$sourceRGName = "Arvinder_RG"
$destRGName = "Arvinder_RG"

$sourceStorageKey = Get-AzureRmStorageAccountKey -ResourceGroupName $sourceRGName -Name $sourcestorageaccount

$destStorageKey = Get-AzureRmStorageAccountKey -ResourceGroupName $destRGName -Name $deststorageaccount

$sourceContext = New-AzureStorageContext -StorageAccountName $sourcestorageaccount -StorageAccountKey $sourceStorageKey.Value[0]
$destContext = New-AzureStorageContext -StorageAccountName $deststorageaccount -StorageAccountKey $destStorageKey.Value[0]

New-AzureStorageContainer -Name $destContainer -Context $destContext

$copiedBlob = Start-AzureStorageBlobCopy  -SrcBlob $blobName -SrcContainer $sourcecontainer -Context $sourceContext -DestContainer $destcontainer -DestBlob $blobName -DestContext $destContext 

# Used to monitor the progress of the copy
$copiedBlob | Get-AzureStorageBlobCopyState