# 2026-09-17 - Bicep network foundation

**Status:** In progress

## Problem

Astra needs a repeatable Azure deployment approach that develops infrastructure-engineering skills rather than relying only on portal-driven configuration. Bicep has been selected as the initial Azure IaC language in ADR-001, but the decision still needs practical implementation and validation.

## Objective

Create the smallest useful Astra network foundation while learning Bicep through a real lab change:

- one VNet;
- one workload subnet;
- one NSG;
- parameterised addressing and location;
- outputs for deployed resource identifiers;
- mandatory `what-if` before deployment.

## Learning focus

Existing programming experience means the learning emphasis is not basic variables or object syntax. The focus is on:

- declarative desired state;
- ARM resource types and API versions;
- resource scope;
- symbolic names;
- parent/child resources;
- implicit dependencies created by resource references;
- deployment parameters versus internal variables;
- repeatability and idempotent deployment behaviour.

## Implementation added

- `infra/bicep/main.bicep`
- `infra/bicep/main.bicepparam`
- `infra/bicep/README.md`

The first implementation intentionally contains no VM, public IP or workload-specific inbound security rule.

## Architecture

```text
Resource Group
|
+-- Virtual Network
|   +-- workload subnet
|       +-- NSG association
|
+-- Network Security Group
```

## Safety boundary

- Deploy only to an authorised personal Azure lab subscription.
- Use a dedicated resource group.
- Review address-space overlap before deployment.
- Run `what-if` before `create`.
- Do not add compute until the networking stage is understood and validated.
- Do not treat generated deployment output as evidence of success until the deployed state has been checked.

## Validation required

1. `az bicep build` succeeds.
2. `what-if` shows only the expected VNet, subnet and NSG changes.
3. Deployment completes successfully in the dedicated lab resource group.
4. Azure CLI queries confirm the expected resources and address ranges.
5. A second identical deployment does not create duplicate resources or unexpected changes.
6. The deployment output and observations are recorded in the experiment/evidence record.

## Next action

Review the Bicep line by line, run a local build, then perform `what-if`. Deployment should follow only after the preview is understood.
