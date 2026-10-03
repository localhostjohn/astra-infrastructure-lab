# 2026-10-03 — Astra PKI and device trust Phase 1

**Status:** Validated  
**Tags:** `security`, `identity`, `containers`, `operations`

## Problem / opportunity

Astra already used private HTTPS for internal services, but trusted devices had no individual certificate identity. The goal was to add an internal device-trust layer that could be used selectively for sensitive administration paths without forcing mutual TLS on every service.

## Requirements and constraints

- Preserve the existing private HTTPS service path and avoid breaking working reverse-proxy hosts.
- Introduce a proper issuing hierarchy rather than use the root CA for routine certificate issuance.
- Issue a unique client certificate to the first trusted Windows administrator endpoint.
- Validate both the positive and negative mTLS paths.
- Keep a recovery path for critical administration services.
- Keep CA private keys, client private keys, PFX files, passwords, exact private addresses and exact internal test hostnames out of the public repository.

## Options considered

### Root CA signs all certificates directly

Simple, but increases exposure of the root key and makes day-to-day certificate issuance depend on the highest-trust key.

### Two-tier internal PKI

Use the Astra Root CA to sign an Astra Internal Issuing CA, then use the issuing CA for service and client certificates. This adds operational structure and better separates long-lived root trust from routine issuance.

### mTLS on every service

Provides a strong device gate but would add unnecessary friction and could create lockout or compatibility problems for normal services and recovery paths.

### Selective mTLS

Use client-certificate authentication only on sensitive administration endpoints, while leaving general internal services on normal HTTPS.

## Decision / approach

A two-tier internal PKI was implemented:

```text
Astra Root CA
    ↓
Astra Internal Issuing CA
    ↓
Service and client certificates
```

The first Windows administrator endpoint received a unique client certificate with TLS Web Client Authentication usage. Nginx Proxy Manager was configured with an Astra client-CA trust bundle and a dedicated private test proxy was used to validate mTLS.

mTLS will be applied selectively rather than universally.

## Implementation

The work included:

1. validating the existing Astra Root CA and protecting its private key;
2. creating and signing the Astra Internal Issuing CA;
3. validating the issuing-CA chain back to the root;
4. issuing the first Windows client certificate;
5. packaging and installing the certificate on the Windows endpoint;
6. configuring a client-CA bundle in Nginx Proxy Manager;
7. creating a dedicated private mTLS test proxy;
8. updating the backend application allow-list so the test hostname could reach the application;
9. cleaning up temporary certificate-transfer files and an orphaned Docker network.

Stable architecture and validation summaries are recorded in the main Astra documentation rather than duplicating configuration details here.

## Validation

Acceptance checks:

- issuing CA verifies against the Astra Root CA;
- client certificate has TLS Web Client Authentication EKU;
- Windows builds the full certificate chain without trust errors;
- browser access succeeds when the Astra client certificate is presented;
- a client that does not present a certificate is rejected before backend access;
- Nginx configuration remains syntactically valid.

All listed acceptance checks passed on 3 October 2026.

## Results / measurements

| Check | Result |
| --- | --- |
| Root → issuing CA verification | Passed |
| Client certificate EKU | TLS Web Client Authentication |
| Windows chain validation | Passed |
| Browser with Astra client certificate | Backend application loaded successfully |
| Request without client certificate | HTTP 400 |
| Nginx configuration test | Passed |

No performance measurement was required for this phase; the purpose was trust-path validation.

## Evidence

Related public-safe records:

- [Reference Architecture](../../architecture.md)
- [Linux, Containers and Operations](../../operations.md)
- [Raspberry Pi Operations and Recovery](../../raspberry-pi-operations.md)
- [Validation and Evidence Register](../../validation.md)
- [Astra Infrastructure Lab Roadmap](../../roadmap.md)
- [ADR-002 — Use a two-tier internal PKI with selective mTLS](../decisions/ADR-002-two-tier-pki-selective-mtls.md)
- [EXP-001 — Validate Astra client-certificate mTLS enforcement](../experiments/EXP-001-validate-astra-mtls-enforcement.md)

## Issues and rollback

Two operational issues were encountered during the work:

- administrative credentials for existing services had to be recovered before configuration could continue;
- Nginx Proxy Manager had stored advanced configuration in its database but did not regenerate the proxy-host configuration until the host was saved again through the application.

A temporary Docker Compose network created during troubleshooting was removed after confirming no containers were attached.

The mTLS test was intentionally isolated from existing production-like proxy hosts, so rollback consisted of removing the test proxy and its DNS record without affecting normal service access.

## Lessons learned

- Certificate-chain correctness and application reachability are separate validation layers.
- A successful client-certificate prompt does not by itself prove the backend application will accept the requested host header.
- Positive and negative tests are both necessary to prove mTLS enforcement.
- Recovery access should remain outside the control path being tested.
- Keeping the root CA out of routine issuance makes the trust model easier to reason about and operate.

## Next actions

Phase 2 will issue unique client certificates to additional trusted administrator devices, validate each against the existing mTLS test path, and then selectively protect sensitive administration endpoints such as container and reverse-proxy management while retaining direct recovery access.
