# Astra Automated Infrastructure Documentation

A read-only documentation engine for the Astra Infrastructure Lab.

## v0.2 scope

The collector discovers the Raspberry Pi host, Linux networking, storage, Docker and Tailscale. It deliberately separates raw discovery from public-safe documentation.

Run on `astra-pi` from the repository root:

```bash
python3 tools/astra-docs/astra_docs.py
```

## Output model

Private raw discovery is written locally to:

```text
.astra-docs/private/inventory.json
```

The entire `.astra-docs/` directory is Git-ignored and must never be committed.

Public-safe output is written to:

```text
docs/generated/
├── sanitized-inventory.json
└── astra-runbook.md
```

The runbook is generated from the sanitised inventory only.

## Sanitisation

v0.2 redacts common infrastructure identifiers including IPv4, IPv6, MAC addresses, long machine/container/hash identifiers, Tailscale account identifiers and Tailscale device names.

Sanitisation is a safety control, not a guarantee. Review generated files before publishing.

## Safety model

- Collection commands are read-only.
- No passwords, tokens or private keys are intentionally collected.
- Raw discovery remains local in a Git-ignored private directory.
- Public documentation is generated only from sanitised data.
- AI/API integration remains out of scope until the sanitisation pipeline is validated.

## Planned collectors

- Azure resource inventory
- Windows Server / Active Directory
- DNS and service dependencies
- Bicep desired-state comparison
- diagram generation
- scheduled documentation refresh
