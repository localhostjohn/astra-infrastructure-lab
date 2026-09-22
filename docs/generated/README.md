# Generated Astra Documentation

This directory contains the **public-safe** output of the Astra automated documentation engine in `tools/astra-docs/`.

## Expected generated files

- `sanitized-inventory.json` — redacted structured discovery
- `astra-runbook.md` — operational snapshot rendered from the sanitised inventory

Raw discovery is **not** stored here. It is written to `.astra-docs/private/inventory.json`, and `.astra-docs/` is excluded by the repository root `.gitignore`.

Generated files can still contain environment-specific information. Review them before committing to the public repository.

The directory README is tracked so the output location exists before the first live scan.
