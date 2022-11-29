@description('List of the container names to be created')
param containerNames array

@description('Name of storage account')
param storageName string = 'storage${uniqueString(resourceGroup().id)}'

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' existing = {
  name: storageName
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = [for containerName in containerNames: {
  name: '${storage.name}/default/${containerName}'
}]
