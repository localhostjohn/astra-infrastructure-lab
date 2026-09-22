# Astra Automated Infrastructure Documentation

A read-only documentation engine for the Astra Infrastructure Lab.

## v0.1 scope

The first milestone discovers the Raspberry Pi host, Linux networking, storage, Docker and Tailscale, then writes structured JSON and a Markdown runbook.

The collector does **not** change infrastructure. Commands are deliberately read-only.

## Quick start

Run on `astra-pi` from the repository root:

```bash
python3 tools/astra-docs/astra_docs.py
```

Outputs are written to `docs/generated/`:

- `inventory.json` — structured discovered state
- `astra-runbook.md` — generated human-readable runbook
- `sanitized-inventory.json` — redacted copy suitable for later AI-assisted processing

## Safety model

- No passwords, tokens or private keys are intentionally collected.
- Collection commands are read-only.
- A sanitised copy is produced before any future LLM integration.
- Raw discovery output should be reviewed before committing it to a public repository.
- AI/API integration is intentionally out of scope for v0.1.

## Planned collectors

- Azure resource inventory
- Windows Server / Active Directory
- DNS and service dependencies
- Bicep desired-state comparison
- diagram generation
- scheduled documentation refresh
