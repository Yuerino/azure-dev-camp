@description('Name for this ssh key')
param sshKeyName string

@description('Location of this resource')
param location string = resourceGroup().location

@description('SSH public key in OpenSSH format')
param sshPublicKey string

var resourceName = 'ssh-${sshKeyName}'
resource sshPublicKeys 'Microsoft.Compute/sshPublicKeys@2022-08-01' = {
  name: resourceName
  location: location
  properties: {
    publicKey: sshPublicKey
  }
}

output sshPublicName string = sshPublicKeys.name
