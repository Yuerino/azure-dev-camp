@description('Location of the virtual network')
param location string = resourceGroup().location

@description('Allow SSH inbound traffic')
param allowSshInbound bool = true

@description('Prefix for network security group name')
param nsgPrefix string = 'nsg'

var nsgName = '${nsgPrefix}-${uniqueString(resourceGroup().id)}'
resource nsg 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: [
      allowSshInbound ? {
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
      } : {}
    ]
  }
}

@description('Prefix for the virtual network name')
param vnetPrefix string = 'vnet'

@description('Address blocks reserved for this virtual network in CIDR notation')
param addressPrefix string = '10.0.0.0/16'

@description('Prefix for the subnet name')
param subnetPrefix string = 'subnet'

@description('The address prefix for the subnet')
param subnetAddressPrefix string = '10.0.0.0/24'

var vnetName = '${vnetPrefix}-${uniqueString(resourceGroup().id)}'
var subnetName = '${subnetPrefix}-${uniqueString(resourceGroup().id)}'
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
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

output subnetId string = vnet.properties.subnets[0].id
output nsgId string = nsg.id
