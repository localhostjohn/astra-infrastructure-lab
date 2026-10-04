# Astra Bicep - Network Foundation

This folder is both a real Astra infrastructure-as-code workstream and a learning path for Bicep. The first stage deliberately stays small: one virtual network, one subnet and one network security group.

## What this stage teaches

### `param`
Values supplied to the deployment from outside the template.

```bicep
param environment string = 'lab'
```

Think of a parameter as an input contract rather than a JavaScript variable.

### `var`
An internal value derived inside the template.

```bicep
var namePrefix = 'astra-${environment}'
```

### `resource`
A desired Azure resource, not an instruction to execute a create function.

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2025-05-01' = {
  // ...
}
```

The symbolic name `vnet` is how other Bicep declarations refer to that resource.

### Resource relationships

The subnet declares:

```bicep
parent: vnet
```

and references:

```bicep
id: workloadNsg.id
```

Those references express relationships and allow Bicep/ARM to infer deployment dependencies. We do not need a JavaScript-style sequence such as `createVnet(); createNsg(); createSubnet();`.

### `output`
Outputs expose useful deployment results such as the generated Azure resource ID.

## Architecture in this stage

```text
Resource Group
|
+-- astra-lab-vnet
|   |
|   +-- workload subnet
|       |
|       +-- associated NSG
|
+-- astra-lab-workload-nsg
```

No VM, public IP, NAT Gateway or paid monitoring resource is created in this lesson.

## Before deployment

Use a dedicated Astra lab resource group. Do not point this at an employer subscription or production environment.

Check the Azure CLI and Bicep tooling:

```powershell
az version
az bicep version
```

Compile the template locally:

```powershell
az bicep build --file .\infra\bicep\main.bicep
```

The generated ARM JSON is a build artefact for learning/debugging; it does not need to be committed.

## Create a dedicated resource group

Example:

```powershell
az group create `
  --name rg-astra-bicep-lab-uks `
  --location uksouth
```

A resource group alone does not deploy the network. It gives this learning workstream a bounded scope.

## Mandatory preview

Before creating anything, run `what-if`:

```powershell
az deployment group what-if `
  --resource-group rg-astra-bicep-lab-uks `
  --template-file .\infra\bicep\main.bicep `
  --parameters .\infra\bicep\main.bicepparam
```

Review the proposed resources and confirm that the address ranges do not overlap any Astra network you intend to connect later.

## Deployment

Only after `what-if` matches the intended design:

```powershell
az deployment group create `
  --name astra-network-foundation `
  --resource-group rg-astra-bicep-lab-uks `
  --template-file .\infra\bicep\main.bicep `
  --parameters .\infra\bicep\main.bicepparam
```

## Validation

After deployment, confirm:

```powershell
az network vnet show `
  --resource-group rg-astra-bicep-lab-uks `
  --name astra-lab-vnet `
  --output table

az network nsg show `
  --resource-group rg-astra-bicep-lab-uks `
  --name astra-lab-workload-nsg `
  --output table
```

Then run the same deployment again. A repeat deployment should converge on the same declared configuration instead of creating duplicate resources. Record the output in the Engineering Journal rather than assuming repeatability.

## Why there are no custom NSG rules yet

The objective of Lesson 1 is to understand resource declarations, inputs, relationships and deployment behaviour. Adding SSH or application ingress before a workload exists would add unnecessary security configuration and distract from the first learning objective.

The next stage will introduce a NIC and then a small Ubuntu workload only after the network foundation has been reviewed and validated.

## Safety / cost boundary

This stage intentionally contains only the VNet, subnet and NSG foundation. It does not create compute. Before later stages add an Ubuntu VM, the proposed size, region, estimated cost, shutdown strategy and teardown process must be reviewed.
