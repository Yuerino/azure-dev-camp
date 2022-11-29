param namePrefix string = 'storage'
param blobPrefix string = 'blob'

param storageName string = '${namePrefix}${uniqueString(resourceGroup().id)}'
param location string = resourceGroup().location
param globalRedundancy bool = false

resource storage 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageName
  location: location
  sku: {
    name: globalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource blobStorage 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-05-01' = {
  name: '${storage.name}/default/${blobPrefix}'
}

output storageId string = storage.id
output storageName string = storage.name
output blobEndpoint string = storage.properties.primaryEndpoints.blob
