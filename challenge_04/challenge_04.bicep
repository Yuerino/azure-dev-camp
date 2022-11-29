@description('Location of key vault')
param location string = resourceGroup().location

@description('Name of the key vault')
param keyVaultName string = 'devCamp'

@description('Suffix for key vault name')
param keyVaultSuffix string = '-KeyVault'

@description('Name of secret')
param secretName string = 'rootPassword'

@description('Value of secret')
@secure()
param secretValue string

@description('The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault')
param userId string

@description('Property to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault')
param enabledForTemplateDeployment bool = true

resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: '${keyVaultName}${keyVaultSuffix}'
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enabledForTemplateDeployment: enabledForTemplateDeployment
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: userId
        permissions: {
          keys: [
            'all'
          ]
          secrets: [
            'all'
          ]
        }
      }
    ]
  }
}

resource secret 'Microsoft.KeyVault/vaults/secrets@2022-07-01' = {
  name: secretName
  parent: keyVault
  properties: {
    value: secretValue
  }
}
