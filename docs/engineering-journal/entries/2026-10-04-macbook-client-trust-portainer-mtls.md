# 2026-10-04 — MacBook client trust, Portainer mTLS and Portainer upgrade

**Status:** Validated  
**Tags:** `security`, `identity`, `containers`, `operations`, `macos`

## Problem / opportunity

Phase 1 proved Astra mTLS with a Windows administrator endpoint and a non-critical test proxy. The next step was to validate the same device-trust model on macOS, apply it to a real administration service, and then upgrade that service without losing security or recovery access.

## Requirements and constraints

- Issue a unique certificate to the macOS administrator endpoint rather than share the Windows identity.
- Keep trust anchored at the Astra Root CA rather than manually trust the leaf certificate.
- Preserve a direct Portainer recovery path outside Nginx Proxy Manager.
- Take a backup before the Portainer upgrade.
- Preserve Portainer data, Docker socket access, restart behaviour and published HTTPS access.
- Revalidate mTLS after the application upgrade.
- Keep private keys, PFX files, passwords, live private addresses and exact internal hostnames out of the public repository.

## Implementation

The MacBook received a client certificate from the Astra Internal Issuing CA with TLS Web Client Authentication usage. The Astra Root CA was installed into the macOS System keychain as the trust anchor, while the MacBook leaf certificate remained a separate client-authentication identity. Positive browser access succeeded and the no-client-certificate path returned HTTP 400.

Portainer was then protected with selective mTLS through Nginx Proxy Manager while its direct management port remained available as a recovery route.

Before upgrading Portainer, the persistent data volume was archived and the running container configuration was inspected. Portainer was recreated from the current LTS image with the same persistent volume, Docker socket bind, restart policy and published HTTPS port. Portainer startup logs showed an internal backup and database migration from 2.45.0 to 2.45.1.

## Upgrade incident and troubleshooting

The first protected-hostname test after the upgrade returned HTTP 502 even though direct Portainer access worked.

Testing showed:

- the Pi host could reach Portainer over its published HTTPS port;
- the Nginx Proxy Manager container could also reach the same host-published Portainer endpoint;
- the generated NPM configuration was still forwarding to the Docker hostname `portainer`.

The previous Portainer container had been reachable through a Docker networking relationship that was lost when the container was recreated with a standalone `docker run`. The NPM upstream therefore depended on container-name resolution that no longer existed.

The proxy upstream was changed from the container name to the Pi host's stable management address and published Portainer HTTPS port. Nginx configuration validation then passed and the protected path recovered.

## Validation

| Check | Result |
| --- | --- |
| macOS client certificate chain | Passed |
| macOS positive mTLS path | Passed |
| macOS no-client-certificate test | HTTP 400 |
| Portainer protected path before upgrade | Passed |
| Pre-upgrade Portainer data backup | Created |
| Portainer database migration | 2.45.0 → 2.45.1 |
| Running Portainer version | 2.45.1 |
| Direct Portainer access after upgrade | Passed |
| NPM → Portainer host-published connectivity | Passed |
| Nginx configuration after upstream repair | Passed |
| Protected Portainer path after repair | Passed |
| No-client-certificate Portainer test | HTTP 400 |
| Direct recovery path after upgrade | Passed |

The first short-timeout curl test returned status `000`, but a verbose Windows Schannel test completed the TLS renegotiation and returned the expected `400 No required SSL certificate was sent`. The verbose result is the authoritative negative-control result.

## Lessons learned

- Server trust and client authentication are separate PKI concerns.
- Trust should be anchored at the CA, not manually forced onto each device leaf certificate.
- Recreating a container can change its network relationships even when volumes, ports and restart settings are preserved.
- Container-name resolution should be treated as an explicit Docker-network dependency.
- A successful application upgrade is not complete until reverse proxy, security controls and recovery access are revalidated.
- Positive access, negative rejection and bypass/recovery access are all required before declaring an admin-service change complete.

## Evidence

- [Reference Architecture](../../architecture.md)
- [Linux, Containers and Operations](../../operations.md)
- [Raspberry Pi Operations and Recovery](../../raspberry-pi-operations.md)
- [Validation and Evidence Register](../../validation.md)
- [Astra Infrastructure Lab Roadmap](../../roadmap.md)
- [ADR-002 — Use a two-tier internal PKI with selective mTLS](../decisions/ADR-002-two-tier-pki-selective-mtls.md)
- [EXP-002 — Validate Portainer selective mTLS and upgrade recovery](../experiments/EXP-002-validate-portainer-selective-mtls.md)

## Next actions

Do not protect Nginx Proxy Manager itself until its direct/bypass recovery path is explicitly designed and tested. Review whether the Portainer-to-NPM relationship should remain host-published or move to a deliberately managed user-defined Docker network as part of the wider Docker operational audit.
