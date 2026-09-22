# Astra Automated Infrastructure Documentation

A read-only documentation engine for the Astra Infrastructure Lab.

## v0.3 scope

The collector discovers the Raspberry Pi host, Linux networking, storage, Docker and Tailscale, then separates private raw discovery from public-safe documentation.

Run on `astra-pi` from the repository root:

```bash
python3 tools/astra-docs/astra_docs.py
```

## Output model

Private raw discovery:

```text
.astra-docs/private/inventory.json
```

The entire `.astra-docs/` directory is Git-ignored and must never be committed.

Public-safe output:

```text
docs/generated/
├── sanitized-inventory.json
├── astra-runbook.md
└── astra-topology.md
```

## v0.3 improvements

- Docker collection is allow-listed to container name, image, status, ports and network membership.
- Docker labels, Compose paths, container IDs and unrelated image metadata are excluded from the public model.
- The runbook renders Docker containers as a readable Markdown table.
- `astra-topology.md` generates a Mermaid diagram from observed Docker network membership.
- Topology generation does not invent application dependencies.
- The Markdown renderer now emits real line breaks rather than escaped newline text.

## Sanitisation

The public pipeline redacts common infrastructure identifiers including IPv4, IPv6, MAC addresses, long machine/container/hash identifiers, Tailscale account identifiers and Tailscale device names.

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
- richer deterministic topology
- scheduled documentation refresh
