@description('Prefix of storage account name')
param storageNamePrefix string = 'storage'

@description('Blob container name')
param blobName string = 'blob'

@description('Storage account name')
param storageName string = '${storageNamePrefix}${uniqueString(resourceGroup().id)}'

@description('Location for storage account')
param location string = resourceGroup().location

@description('Use global SKU or not')
param globalRedundancy bool = false

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageName
  location: location
  sku: {
    name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storage.name}/default/${blobName}'
}

output storageId string = storage.id
output storageName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
