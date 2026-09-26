using './main.bicep'

param environment = 'lab'
param location = 'uksouth'

// Example lab ranges only. Run `what-if` and check existing VNets before deployment.
param vnetAddressPrefix = '10.60.0.0/16'
param workloadSubnetPrefix = '10.60.10.0/24'
