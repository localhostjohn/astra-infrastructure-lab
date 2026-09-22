# Generated Astra Documentation

This directory contains the **public-safe** output of the Astra automated documentation engine in `tools/astra-docs/`.

## Expected generated files

- `sanitized-inventory.json` — redacted structured discovery
- `astra-runbook.md` — operational snapshot rendered from sanitised inventory
- `astra-topology.md` — Mermaid topology generated from observed Docker network membership

Raw discovery is **not** stored here. It is written to `.astra-docs/private/inventory.json`, and `.astra-docs/` is excluded by the repository root `.gitignore`.

The v0.3 public Docker model intentionally excludes labels, Compose paths, container IDs and unrelated image metadata. The topology shows only relationships supported by collected data and does not infer application-level dependencies.

Generated files can still contain environment-specific information. Review them before committing to the public repository.
