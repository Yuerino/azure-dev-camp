@description('Location for the deployment')
param location string = resourceGroup().location

@description('Prefix for public IP name')
param publicIpPrefix string = 'public-ip'

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

var publicIpName = '${publicIpPrefix}-${vmName}'
resource publicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  properties: {
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

@description('Prefix for network interface name')
param nicPrefix string = 'nic'

@description('ID of subnet')
param subnetId string

@description('ID of network security group')
param nsgId string

var nicName = '${nicPrefix}-${vmName}'
resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
  }
}

@description('Name of virtual machine')
param vmName string

@description('Prefix for virtual machine name')
param vmPrefix string = 'vm'

@description('Size of virtual machine')
param vmSize string = 'Standard_B1s'

@description('Admin username of the virtual machine')
param adminUsername string

@description('Admin password of the virtual machine')
@secure()
param adminPassword string

@description('SSH public key file for the virtual machine')
param sshPublicKey string

var vmResourceName = '${vmPrefix}-${vmName}'
resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmResourceName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
      }
      imageReference: {
        publisher: 'Debian'
        offer: 'debian-10'
        sku: '10'
        version: 'latest'
      }
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      linuxConfiguration: {
        disablePasswordAuthentication: false
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: sshPublicKey
            }
          ]
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output adminUserName string = adminUsername
output hostname string = publicIP.properties.dnsSettings.fqdn
