@description('Azure region for network resources.')
param location string

@description('Virtual network name.')
param vnetName string

@description('Security subnet name.')
param subnetName string

@description('Virtual network address space.')
param vnetAddressPrefix string

@description('Security subnet address prefix.')
param subnetAddressPrefix string

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
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

output vnetId string = vnet.id
output subnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', vnet.name, subnetName)
