@description('Azure region for the Network Security Group.')
param location string

@description('Network Security Group name.')
param nsgName string

@description('Optional CIDR allowed to use SSH during bootstrap.')
param bootstrapSshSourceCidr string = ''

var sshRule = empty(bootstrapSshSourceCidr) ? [] : [
  {
    name: 'Allow-SSH-Bootstrap'
    properties: {
      priority: 100
      access: 'Allow'
      direction: 'Inbound'
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: bootstrapSshSourceCidr
      destinationAddressPrefix: '*'
    }
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: sshRule
  }
}

output nsgId string = nsg.id
output nsgName string = nsg.name
