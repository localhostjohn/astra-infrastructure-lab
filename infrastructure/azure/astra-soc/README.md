# Astra SOC — Azure Infrastructure as Code

This directory will contain the Bicep templates used to deploy the Azure foundation for the `astra-soc` Ubuntu VM.

## Goals

- Keep the deployment small and understandable.
- Parameterise environment-specific values.
- Avoid secrets in source control.
- Validate templates before deployment.
- Document deployment and teardown.
- Use this project as a practical Bicep learning exercise.

## Planned structure

```text
infrastructure/azure/astra-soc/
├── README.md
├── main.bicep
├── main.bicepparam.example
└── modules/
    ├── network.bicep
    ├── nsg.bicep
    └── vm.bicep
```

## Initial deployment scope

The first iteration should deploy only the Azure foundation required for the SOC host:

- Virtual network
- Security subnet
- Network Security Group
- Network interface
- Ubuntu virtual machine
- SSH public-key authentication
- Useful outputs for validation

Wazuh, Docker and application configuration should remain separate from the first infrastructure deployment so the Azure layer can be understood and validated independently.

## Suggested workflow

```bash
az login
az account show
az bicep version
az bicep build --file main.bicep
```

Before creating resources, validate the deployment at the intended scope. The exact command will depend on whether the first template is resource-group scoped or subscription scoped.

After validation, deploy with explicitly reviewed parameters. Do not paste passwords, private keys or auth tokens into command history or committed parameter files.

## Parameters

The example parameter file should contain safe defaults or placeholders only. Likely parameters include:

- Azure location
- VM name
- VM size
- administrator username
- SSH public key
- VNet address prefix
- subnet prefix
- resource tags

The real SSH public key may be supplied at deployment time rather than committed if preferred.

## Security

Do not commit:

- SSH private keys
- Passwords
- Azure credentials
- Tailscale auth keys
- Wazuh credentials
- API keys
- Subscription or tenant data unless intentionally sanitised
- Real public-IP allowlists

Public management access should be temporary and tightly restricted where required for initial bootstrap. Routine administration should move to a private management path once validated.

## Teardown

The project will include a documented cleanup step. Resource deletion should be verified before the workstream is described as fully repeatable.

## Status

Documentation foundation created. Bicep implementation is the next stage.
