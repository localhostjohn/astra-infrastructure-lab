# ADR-002 — Use a two-tier internal PKI with selective mTLS

**Status:** Accepted  
**Date:** 2026-10-03  
**Tags:** `architecture`, `security`, `identity`

## Context

Astra requires trusted HTTPS for private services and a stronger device-trust mechanism for selected administration endpoints. The existing private CA established server trust, but using the root key for routine issuance and applying client-certificate authentication everywhere would create unnecessary operational risk and friction.

A decision was required on both the internal CA hierarchy and where mTLS should be enforced.

## Decision drivers

- Protect the root CA from routine day-to-day issuance.
- Support unique client identities for trusted administrator endpoints.
- Allow revocation/replacement of individual device certificates without replacing the root.
- Preserve simple HTTPS access for services that do not need device authentication.
- Avoid lockout of critical recovery paths.
- Keep the design understandable and appropriate for a small infrastructure lab.
- Provide a repeatable security control that can be validated with positive and negative tests.

## Options considered

### Single-tier CA

The Astra Root CA could continue signing service and client certificates directly.

**Benefits:** simplest design and fewer certificate-chain components.  
**Risks:** routine issuance requires access to the highest-trust private key and creates weaker separation of duties.

### Two-tier CA with blanket mTLS

A Root CA signs an Issuing CA, and every private service requires a client certificate.

**Benefits:** strong device gate across the entire service estate.  
**Risks:** unnecessary friction, compatibility issues, and greater chance of operational lockout.

### Two-tier CA with selective mTLS

A Root CA signs an Internal Issuing CA. The issuing CA signs service and client certificates. mTLS is enabled only for sensitive administration endpoints where device trust adds material value.

**Benefits:** root-key separation, per-device identity, bounded enforcement and preserved recovery paths.  
**Risks:** more certificate lifecycle work and a requirement to track which endpoints require client authentication.

## Decision

Use a **two-tier internal PKI** consisting of:

```text
Astra Root CA
    ↓
Astra Internal Issuing CA
    ↓
Service and client certificates
```

Use **selective mTLS** at the reverse proxy for sensitive administration endpoints rather than applying client-certificate authentication to every Astra service.

Each trusted administrator device should receive its own client certificate. Critical services must retain a documented recovery route that does not depend on the same certificate/authentication chain being protected.

## Consequences

### Positive

- The root private key is no longer needed for routine endpoint issuance.
- Individual administrator devices can have unique certificate identities.
- mTLS can be added where it materially improves the security boundary.
- General private services remain easier to use.
- Positive and negative mTLS tests can be repeated as an acceptance control.
- Compromise or retirement of one client certificate does not require replacing the trust anchor.

### Negative / trade-offs

- Client certificates require lifecycle management, secure private-key storage and renewal.
- Additional administrator devices need certificate provisioning before they can reach protected services.
- Reverse-proxy and application host-validation behaviour must both be understood.
- Recovery paths must be maintained and tested to avoid certificate-related lockout.
- Revocation handling should be improved as the number of client certificates grows.

## Validation

The decision was validated on 3 October 2026 by:

1. verifying the issuing CA against the root CA;
2. issuing a Windows client certificate with TLS Web Client Authentication usage;
3. validating the full certificate chain on the client;
4. configuring a dedicated reverse-proxy test path requiring Astra-issued client certificates;
5. confirming browser access succeeded when the client certificate was presented;
6. confirming a request without a client certificate was rejected with HTTP 400;
7. confirming the Nginx configuration remained valid.

## Revisit when

Revisit this decision if:

- Astra adds enough devices that manual certificate lifecycle management becomes burdensome;
- automated enrolment or MDM-backed certificate deployment becomes appropriate;
- certificate revocation requirements become more formal;
- an application cannot operate reliably behind mTLS;
- the recovery model changes;
- a different identity-aware proxy or device-attestation mechanism replaces client certificates.

## Related records

- [2026-10-03 — Astra PKI and device trust Phase 1](../entries/2026-10-03-astra-pki-device-trust-phase-1.md)
- [EXP-001 — Validate Astra client-certificate mTLS enforcement](../experiments/EXP-001-validate-astra-mtls-enforcement.md)
- [Reference Architecture](../../architecture.md)
- [Validation and Evidence Register](../../validation.md)
