@description('Location for the deployment')
param location string = resourceGroup().location

@description('Name of the key vault')
param keyVaultName string = 'devCamp'

@description('Suffix for key vault name')
param keyVaultSuffix string = '-KeyVault'

var keyVaultResourceName = '${keyVaultName}${keyVaultSuffix}'
resource kv 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultResourceName
}

@description('Prefix for public ssh key name')
param publicSshPrefix string = 'ssh'

var sshResourceName = '${publicSshPrefix}-${sshPublicKeyName}'
resource sshKey 'Microsoft.Compute/sshPublicKeys@2022-08-01' existing = {
  name: sshResourceName
}

@description('Prefix for the virtual network module')
param vnetModulePrefix string = 'vnet-module'

var vnetModuleName = '${vnetModulePrefix}-${uniqueString(resourceGroup().id)}'
module virtualNetworkModule 'network.bicep' = {
  name: vnetModuleName
  params: {
    location: location
  }
}

@description('Prefix for the virtual machine module name')
param vmModulePrefix string = 'vm-module'

@description('Name of virtual machine')
param vmName string

@description('Admin username of the virtual machine')
param adminUsername string

@description('SSH public key name for the virtual machine')
param sshPublicKeyName string

var vmModuleName = '${vmModulePrefix}-${vmName}'
module virtualMachineModule 'vm.bicep' = {
  name: vmModuleName
  params: {
    vmName: vmName
    location: location
    adminUsername: adminUsername
    adminPassword: kv.getSecret('adminPassword')
    sshPublicKey: sshKey.properties.publicKey
    subnetId: virtualNetworkModule.outputs.subnetId
    nsgId: virtualNetworkModule.outputs.nsgId
  }
}
