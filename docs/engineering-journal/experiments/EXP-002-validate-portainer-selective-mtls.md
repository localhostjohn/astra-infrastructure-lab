# EXP-002 — Validate Portainer selective mTLS and upgrade recovery

**Status:** Validated  
**Date:** 2026-10-04  
**Tags:** `experiment`, `security`, `containers`, `operations`

## Question

Can Portainer remain protected by Astra client-certificate authentication and independently recoverable after an application/container upgrade?

## Hypothesis

If Portainer data is preserved, the reverse-proxy path is validated after recreation, and mTLS remains configured at Nginx Proxy Manager, trusted administrator devices should continue to reach Portainer, clients without a certificate should be rejected, and the direct management path should remain available.

## Safety / scope boundary

A data-volume backup was created before the upgrade. The direct Portainer management path was preserved so proxy or mTLS failure would not prevent recovery.

## Acceptance criteria

- Portainer starts on version 2.45.1 with its existing data.
- Portainer's internal database migration completes.
- Direct Portainer access remains available.
- Nginx Proxy Manager can reach the Portainer upstream.
- Nginx configuration validates after any repair.
- A trusted Astra client certificate reaches the protected Portainer path.
- A request without a client certificate returns HTTP 400.
- Recovery access remains independent of Nginx Proxy Manager.

## Results

| Test | Observed result | Status |
| --- | --- | --- |
| Pre-upgrade backup | Created | Passed |
| Portainer startup | 2.45.1 running | Passed |
| Database migration | 2.45.0 → 2.45.1 completed | Passed |
| Direct Portainer path | HTTP application reachable | Passed |
| Initial reverse-proxy test | HTTP 502 | Failed / investigated |
| NPM → host-published Portainer | HTTP 200 | Passed |
| Root cause | Proxy depended on Docker hostname no longer reachable after recreation | Identified |
| Upstream repair | Changed to stable host-published Portainer endpoint | Completed |
| Nginx syntax validation | Successful | Passed |
| Positive mTLS path | Trusted device reached Portainer | Passed |
| Negative mTLS path | HTTP 400, no client certificate sent | Passed |
| Direct recovery path | Still reachable | Passed |

## Interpretation

The application upgrade itself succeeded, but recreating the container exposed an undocumented Docker-network dependency in the reverse-proxy configuration. The failure was not caused by Portainer 2.45.1 or by mTLS. NPM could reach the host-published Portainer service, but could no longer use the former Docker hostname path.

Moving the upstream to a stable host-published endpoint restored service while preserving the direct recovery path. The experiment therefore validates both the security control and the value of independent recovery access.

## Limitations

- The current design uses the host-published Portainer endpoint rather than a dedicated shared Docker proxy network.
- Certificate revocation was not tested.
- A full restore from the pre-upgrade backup was not required because the migration succeeded.
- Nginx Proxy Manager itself is not yet protected by mTLS.

## Follow-up

Consider whether a deliberately managed user-defined Docker network would be preferable to the host-published upstream during the broader Docker operational audit. Do not change the working path without preserving and testing recovery access.
