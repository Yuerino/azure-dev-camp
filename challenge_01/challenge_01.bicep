@description('Name of the storage account')
param name string

@description('Azure region of the deployment')
param location string = 'germanywestcentral'

resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

output storageId string = storage.id
