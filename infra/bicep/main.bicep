targetScope = 'resourceGroup'

@description('Azure region for the Astra lab resources.')
param location string = resourceGroup().location

@description('Short environment label used in Astra resource names.')
@allowed([
  'lab'
  'dev'
])
param environment string = 'lab'

@description('Address space for the Astra virtual network. Validate that it does not overlap any network you may later connect to.')
param vnetAddressPrefix string

@description('Address space for the first Astra workload subnet.')
param workloadSubnetPrefix string

// Variables are internal values derived from deployment inputs.
var namePrefix = 'astra-${environment}'
var commonTags = {
  project: 'astra'
  environment: environment
  managedBy: 'bicep'
}

// An NSG exists before we add workload-specific rules. Starting with no custom
// inbound rules keeps this foundation conservative; Azure default NSG rules remain.
resource workloadNsg 'Microsoft.Network/networkSecurityGroups@2025-05-01' = {
  name: '${namePrefix}-workload-nsg'
  location: location
  tags: commonTags
  properties: {
    securityRules: []
  }
}

// A resource declaration describes the desired Azure resource state.
resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  name: '${namePrefix}-vnet'
  location: location
  tags: commonTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
  }
}

// This child resource uses `parent: vnet`, so Bicep understands the relationship
// without us scripting a separate create-subnet step.
resource workloadSubnet 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  parent: vnet
  name: 'workload'
  properties: {
    addressPrefix: workloadSubnetPrefix
    networkSecurityGroup: {
      id: workloadNsg.id
    }
  }
}

output virtualNetworkName string = vnet.name
output virtualNetworkId string = vnet.id
output workloadSubnetName string = workloadSubnet.name
output workloadSubnetId string = workloadSubnet.id
output workloadNsgName string = workloadNsg.name
