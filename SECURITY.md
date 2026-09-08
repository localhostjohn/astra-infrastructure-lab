# Security and Disclosure

This is a personal educational infrastructure repository. It must not contain live secrets, employer configuration, real directory exports or private network inventories.

## Reporting a security concern

Please do not post suspected credentials, private addresses or sensitive findings in a public issue. Contact the maintainer through an appropriate private channel and provide only the minimum information necessary to identify the concern.

## Safe publishing rules

- Use fictional domains, hosts, identities and documentation-only IP addresses in public examples.
- Never commit passwords, API tokens, SSH private keys, Tailscale auth keys, certificates with private keys, `.env` files or backup encryption material.
- Do not publish real AD/Entra exports, tenant or subscription identifiers, employer screenshots or internal configuration.
- Review scripts before publishing, especially destructive commands, privilege changes and network exposure.
- Pin and review dependencies when a runnable example is introduced. Do not claim a configuration is secure or production-ready without testing.
- Preserve an appropriately private copy of evidence when needed, and publish only a sanitised or recreated version.

If a secret is accidentally committed, remove it from the active configuration, revoke or rotate it as appropriate, and assess repository history and downstream exposure. Deleting a file from the latest commit does not remove the secret from Git history.

## Scope

No public bug bounty, penetration-testing authorisation or permission to scan third-party systems is offered by this repository. All exercises are intended for systems owned by the learner or explicitly authorised for testing.
