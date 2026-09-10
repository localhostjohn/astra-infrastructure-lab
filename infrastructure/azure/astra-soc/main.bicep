targetScope = 'resourceGroup'

@description('Azure region for Astra SOC resources.')
param location string = resourceGroup().location

@description('Name of the Astra SOC virtual machine.')
param vmName string = 'astra-soc'

@description('Administrator username for the Linux VM.')
param adminUsername string

@description('SSH public key used for Linux authentication.')
@secure()
param adminSshPublicKey string

@description('Azure VM size for the Astra SOC host.')
param vmSize string = 'Standard_D4as_v5'

@description('Virtual network address space.')
param vnetAddressPrefix string = '10.40.0.0/16'

@description('Security subnet address prefix.')
param subnetAddressPrefix string = '10.40.10.0/24'

@description('Optional CIDR allowed to SSH during bootstrap. Leave empty to create no inbound SSH allow rule.')
param bootstrapSshSourceCidr string = ''

module network './modules/network.bicep' = {
  name: 'astraSocNetwork'
  params: {
    location: location
    vnetName: 'vnet-astra-soc'
    subnetName: 'snet-security'
    vnetAddressPrefix: vnetAddressPrefix
    subnetAddressPrefix: subnetAddressPrefix
  }
}

module nsg './modules/nsg.bicep' = {
  name: 'astraSocNsg'
  params: {
    location: location
    nsgName: 'nsg-astra-soc'
    bootstrapSshSourceCidr: bootstrapSshSourceCidr
  }
}

module vm './modules/vm.bicep' = {
  name: 'astraSocVm'
  params: {
    location: location
    vmName: vmName
    vmSize: vmSize
    adminUsername: adminUsername
    adminSshPublicKey: adminSshPublicKey
    subnetId: network.outputs.subnetId
    networkSecurityGroupId: nsg.outputs.nsgId
  }
}

output vmResourceId string = vm.outputs.vmResourceId
output vmName string = vm.outputs.vmName
output privateIpAddress string = vm.outputs.privateIpAddress
output subnetId string = network.outputs.subnetId
output networkSecurityGroupId string = nsg.outputs.nsgId
