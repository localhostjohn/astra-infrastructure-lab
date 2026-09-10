# Astra SOC — Azure Bicep

This directory contains the first Infrastructure-as-Code implementation for the planned `astra-soc` Ubuntu VM.

## What this deploys

- Virtual network: `vnet-astra-soc`
- Security subnet: `snet-security`
- Network Security Group: `nsg-astra-soc`
- Network interface
- Ubuntu Server 24.04 LTS VM: `astra-soc`
- Trusted Launch with Secure Boot and vTPM
- SSH public-key authentication
- 128 GiB Standard SSD OS disk

No public IP is created by this first version. The VM is deliberately private-first.

## Structure

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

`main.bicep` coordinates three small modules so networking, security rules and compute remain easy to understand while learning Bicep.

## Important networking note

The template can optionally add an inbound TCP/22 NSG rule for a supplied bootstrap CIDR. However, this first iteration intentionally creates **no public IP**, so that rule alone does not make the VM reachable from the internet.

A private management route must exist before SSH will work, for example through a later Tailscale bootstrap method, VPN/jump host, Azure Bastion, or another authorised private path.

This is intentional: Wazuh management and agent-facing services should not be broadly exposed to the public internet.

## Ubuntu image

The VM uses the Azure Marketplace image:

```text
Canonical:ubuntu-24_04-lts:server:latest
```

## Before deployment

Check:

1. Azure CLI is installed and authenticated.
2. The intended subscription is selected.
3. `az bicep version` succeeds.
4. The target resource group exists.
5. The selected VM size is available in the target region.
6. You have a valid SSH public key.
7. `10.40.0.0/16` and `10.40.10.0/24` do not overlap with networks you intend to connect privately.

## Create a local parameter file

Copy the example:

```powershell
Copy-Item .\main.bicepparam.example .\main.bicepparam
```

Then replace the placeholder public key.

The repository ignores `main.bicepparam`, so environment-specific deployment values can remain local.

## Build the Bicep

```powershell
az bicep build --file main.bicep
```

This checks that Bicep can compile the template into an ARM JSON template.

## Validate against Azure

```powershell
az deployment group validate `
  --resource-group <resource-group> `
  --template-file main.bicep `
  --parameters main.bicepparam
```

Validation does not replace a what-if review.

## Preview with what-if

```powershell
az deployment group what-if `
  --resource-group <resource-group> `
  --template-file main.bicep `
  --parameters main.bicepparam
```

Review every proposed resource and property before creating anything.

## Deploy

Only after validation and what-if review:

```powershell
az deployment group create `
  --resource-group <resource-group> `
  --name astra-soc-foundation `
  --template-file main.bicep `
  --parameters main.bicepparam
```

## What this teaches

This first iteration demonstrates:

- Parameters and default values
- Secure parameters
- Modules
- Resource dependencies through module outputs
- Resource IDs
- Conditional NSG rules
- Outputs
- NIC-to-subnet and NSG relationships
- Trusted Launch VM configuration
- SSH-only Linux authentication
- Repeatable Azure deployment

## Security

Do not commit:

- SSH private keys
- Passwords
- Azure credentials
- Tailscale auth keys
- Wazuh credentials
- API keys
- Real public-IP allowlists
- Employer or production information

## Next iteration

After the Bicep compiles and Azure validation succeeds:

1. Decide and implement the private bootstrap/management path.
2. Run `what-if`.
3. Review the resource cost and SKU availability.
4. Deploy the Azure foundation.
5. Establish private SSH access.
6. Patch Ubuntu.
7. Install Docker Engine and Docker Compose.
8. Capture sanitised validation evidence.
9. Begin Wazuh deployment only after the host foundation is stable.

Do not describe `astra-soc` as deployed or validated in portfolio documentation until those tests have actually been completed.
