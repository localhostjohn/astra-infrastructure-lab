# Discord Server Bootstrapper — 9 September 2026

## Summary

A reusable Python-based Discord server bootstrapper was created and successfully used to build the Astra Infrastructure Lab Discord server structure. The tool was then generalized and retained in this repository under `tools/discord-server-bootstrapper/` for future reuse.

## What was implemented

The bootstrapper is configuration-driven and uses a JSON layout to define:

- Roles
- Categories
- Text channels
- Voice channels
- Public, read-only, staff-only and owner-only visibility modes
- Starter messages
- Optional server icon handling

The tool uses a local `.env` file for Discord application details and secrets. The `.env` file is excluded from source control.

## Safety and repeatability

The tool is designed to be non-destructive. Existing matching resources are skipped rather than deleted or replaced. It also requires an explicit `APPLY <server-id>` confirmation before modifying a server.

The reusable version intentionally avoids requesting Discord Administrator permission. It requests only the permissions required for the setup actions it performs.

## Validation recorded

The Astra setup run completed successfully after correcting a category creation issue caused by passing `overwrites=None` to the Discord API wrapper. The fix was incorporated into the reusable version.

The final reusable project includes automated tests for layout validation and setup behaviour. No bot token, `.env` file or other secret material is stored in this public repository.

## Repository location

See:

- [`tools/discord-server-bootstrapper/README.md`](../tools/discord-server-bootstrapper/README.md)
- [`tools/discord-server-bootstrapper/setup.py`](../tools/discord-server-bootstrapper/setup.py)
- [`tools/discord-server-bootstrapper/layout.json`](../tools/discord-server-bootstrapper/layout.json)

## Learning outcomes

This exercise demonstrates:

- Python automation against an external API
- Configuration-driven infrastructure/service setup
- Idempotent and non-destructive automation principles
- Role and channel permission design
- Secrets separation using environment variables
- Reusable tooling and documentation

The tool should be treated as a lab/portfolio automation utility rather than a production-grade Discord provisioning platform.
