@description('Name of virtual machine')
param vmName string

@description('Location for the deployment')
param location string = resourceGroup().location

@description('Size of virtual machine')
param vmSize string = 'Standard_B1s'

@description('Admin username of the virtual machine')
param adminUsername string

@description('Admin password of the virtual machine')
@secure()
param adminPassword string

@description('SSH public key file for the virtual machine')
param sshPublicKey string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id)}')

var publicIpName = 'public-ip-${vmName}'
resource publicIP 'Microsoft.Network/publicIPAddresses@2022-05-01' = {
  name: publicIpName
  location: location
  properties: {
    dnsSettings: {
      domainNameLabel: dnsLabelPrefix
    }
  }
}

var nsgName = 'nsg-${vmName}'
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      {
        name: 'allow-ssh-inbound'
        properties: {
          priority: 690
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '22'
        }
      }
    ]
  }
}

var vnetName = 'vnet-${vmName}'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'subnet-${vmName}'
var subnetPrefix = '10.0.0.0/24'
resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetPrefix
        }
      }
    ]
  }
}

var nicName = 'nic-${vmName}'
resource nic 'Microsoft.Network/networkInterfaces@2022-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: vnet.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIP.id
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsg.id
    }
  }
}

var vmResourceName = 'vm-${vmName}'
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
