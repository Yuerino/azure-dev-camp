@description('Name of virtual machine')
param vmName string

@description('Location for the deployment')
param location string = resourceGroup().location

@description('Size of virtual machine')
param vmSize string = 'Standard_B1s'

@description('Admin username of the virtual machine')
param adminUsername string

@description('SSH public key name for the virtual machine')
param sshPublicKeyName string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

@description('Name of the key vault')
param keyVaultName string = 'devCamp'

@description('Suffix for key vault name')
param keyVaultSuffix string = '-KeyVault'

var keyVaultResourceName = '${keyVaultName}${keyVaultSuffix}'
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultResourceName
}

var sshResourceName = 'ssh-${sshPublicKeyName}'
resource sshKey 'Microsoft.Compute/sshPublicKeys@2022-08-01' existing = {
  name: sshResourceName
}

var vmModuleName = 'vm-module-${vmName}'
module virtualMachine './vm.bicep' = {
  name: vmModuleName
  params: {
    vmName: vmName
    location: location
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: kv.getSecret('adminPassword')
    sshPublicKey: sshKey.properties.publicKey
    dnsLabelPrefix: dnsLabelPrefix
  }
}
