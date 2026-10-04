# Astra Infrastructure Lab Roadmap

Astra is a hybrid infrastructure engineering lab used to design, automate, secure, monitor, troubleshoot and document Windows, Linux, networking and Azure infrastructure.

The current priority is **consolidation rather than expansion**. New services should only be added when they provide a capability the existing platform genuinely lacks and the additional operational complexity is justified.

## Engineering principle

All significant Astra work should move through the same lifecycle:

> **Depth → Automation → Resilience → Documentation**

1. **Depth** — understand the service, dependencies, protocols, security model and failure modes.
2. **Automation** — replace repeatable manual work with version-controlled configuration, scripts, Docker Compose, PowerShell or Bicep where appropriate.
3. **Resilience** — test failure, backup, restore and recovery rather than assuming they work.
4. **Documentation** — record architecture, decisions, validation, incidents, recovery steps and lessons learned.

A workstream is not complete simply because a service is installed.

## NOW — Consolidate the Astra Pi platform

### 1. Establish and maintain a known-good baseline

Keep GitHub documentation aligned with the validated lab state. Verify the sanitised inventory, dependencies, access paths, DNS, time synchronisation, storage, Docker state and recovery information before restructuring services.

**Evidence:** architecture documentation, generated inventory, validation notes and runbooks.

### 2. Service access architecture — Nginx Proxy Manager, PKI and Authentik

Nginx Proxy Manager remains the reverse-proxy/TLS layer and Authentik should provide application authentication only where it adds value. Preserve Tailscale as the remote network-access boundary and retain an emergency management path for critical infrastructure services.

**PKI & Device Trust Phase 2A is complete.** The two-tier internal CA hierarchy is now validated across Windows and macOS administrator endpoints using unique device certificates. Positive and negative mTLS tests have passed on both platforms.

Portainer is the first administration service protected by selective mTLS through Nginx Proxy Manager. A client certificate is required before the Portainer application is reached, and the direct Portainer management path is deliberately retained as a recovery route.

Portainer has also been upgraded from 2.45.0 to 2.45.1 with a pre-change backup and post-upgrade validation. The upgrade exposed a hidden dependency on Docker container-name resolution in the reverse-proxy upstream; the proxy now targets the host-published Portainer service through a stable management address instead. mTLS enforcement and direct recovery access were revalidated after the change.

The next PKI step is to decide whether another trusted device needs enrolment and then design the recovery model for protecting Nginx Proxy Manager itself. Do not protect NPM until its bypass/recovery path has been explicitly tested.

Do not place critical recovery dependencies behind an authentication or certificate chain that could prevent recovery during an Authentik, PKI or reverse-proxy failure. Preserve a documented direct recovery route for critical management services.

**Evidence:** architecture decision, certificate-chain validation, mTLS positive/negative test, protected-service matrix and recovery/bypass procedure.

### 3. DNS — AdGuard Home

Finish the Astra DNS baseline. Keep private DNS and Tailscale Split DNS reliable while applying sensible advertising/tracking/telemetry filtering. Streaming and core service reliability take priority over aggressive blocking.

Document upstream DNS, local/private records at a sanitised level, filtering policy, client behaviour and the recovery path if AdGuard becomes unavailable.

**Evidence:** DNS validation, filtering tests, service-reliability checks and recovery notes.

### 4. Observability rationalisation

Give each existing monitoring component a clear responsibility rather than adding another monitoring product:

- **Prometheus** — metrics collection and time-series data.
- **Grafana** — dashboards and visualisation.
- **Uptime Kuma** — service availability and endpoint checks.
- **NetAlertX** — network-device discovery/presence and change awareness.
- **Homepage** — service portal/status surface, not the monitoring system of record.

Remove unnecessary overlap only after validating that required visibility is retained.

**Evidence:** monitoring responsibility matrix, dependency map, alert/check tests and updated diagrams.

### 5. Docker operational audit

Audit the Pi containers and supporting configuration. For each important service record its purpose, image/version approach, Compose/configuration source, volumes, networks, ports, restart policy, health check, dependencies, secrets handling, backup requirement and recovery method.

Move repeatable configuration into version-controlled, sanitised deployment definitions where safe to do so. Never commit credentials, private keys, live tokens or sensitive infrastructure identifiers.

**Evidence:** service inventory, sanitised Compose/configuration, validation and operational runbook updates.

### 6. Storage validation

Do not place trusted Astra or personal data on storage that has not passed capacity and integrity validation. The previously questionable high-capacity external device remains unsuitable for trusted storage until it is independently verified.

**Evidence:** storage validation results and documented decision before production-like use.

### 7. Backup and recovery

Define what must be backed up, where backups are stored, retention expectations and the exact restore sequence. Include configuration and persistent data needed to rebuild the Pi platform.

Perform a restore test using disposable/test data before treating the backup design as validated. Record checksums or other integrity evidence where appropriate.

The long-term objective is a documented and increasingly automated rebuild path from a fresh Raspberry Pi OS installation to a validated Astra platform.

**Evidence:** backup inventory, restore log, recovery runbook, validation results and measured recovery observations.

### 8. Controlled failure testing

Once the baseline and recovery paths are established, deliberately test representative failures such as a stopped container, DNS outage, broken proxy path or configuration rollback. Diagnose and recover using the documented process.

Record useful failures as engineering evidence rather than hiding them.

**Evidence:** incident/experiment records, diagnosis, root cause, recovery steps and lessons learned.

## NEXT — Azure, Windows and automation

### 9. Continue Azure Infrastructure as Code with Bicep

Complete the current Bicep milestone before expanding the Azure environment. Use parameterised, version-controlled templates for networking, NSGs, NICs and selected compute resources. Validate deployments and teardown while controlling Azure cost.

**Evidence:** Bicep templates, deployment validation, architecture notes and cleanup record.

### 10. Complete the Windows Server infrastructure lab

Bring the existing Azure Windows Server VM online only for planned work sessions. Continue AD DS, DNS, OU/group design, service accounts, delegated administration, GPO and directory-health work.

Prefer repeatable PowerShell checks and configuration where appropriate.

**Evidence:** sanitised scripts, directory design, test matrix, troubleshooting records and validation output.

### 11. Hybrid identity

After the on-premises identity baseline is stable, complete the planned Microsoft Entra hybrid-identity work in controlled scope. Validate UPN design, synchronisation scope, privileged administration, MFA/security controls and lifecycle behaviour before expanding the design.

**Evidence:** architecture decision, synchronisation scope, positive/negative identity tests and rollback notes.

### 12. Automation maturity

Gradually reduce manual rebuild/configuration work using PowerShell, Bicep, Docker Compose and Astra's automated documentation tooling. Automation should solve an understood manual process rather than obscure how the platform works.

**Evidence:** scripts/templates, tests, before/after process documentation and failure handling.

## LATER — justified extensions

These are valuable but should not distract from consolidation:

- Network segmentation/VLAN design and validation.
- Further Intune/endpoint-management lab work.
- Additional resilience or secondary-host experiments.
- Storage/cloud-service expansion after trustworthy storage is available.
- Additional services only where a documented capability gap exists.

The OpenWrt travel router remains a useful standalone networking project. It should be maintained and documented without becoming a dependency of the core Astra platform. Tailscale remains installed on endpoints rather than the travel router.

## Service acceptance standard

An important Astra service should eventually have all of the following documented:

| Area | Required understanding |
| --- | --- |
| Purpose | Why the service exists and what capability it provides |
| Deployment | How it is installed/recreated and where configuration lives |
| Dependencies | DNS, networking, storage, identity and other service dependencies |
| Security | Authentication, exposure, secrets and least-privilege considerations |
| Monitoring | How availability/health is observed |
| Backup | What configuration/data must be protected |
| Recovery | How the service is restored or bypassed during failure |
| Validation | Evidence that the intended path actually works |
| Limitations | What has not yet been proven |

## Change gate for new services

Before adding another platform or container, answer:

1. Does Astra genuinely lack this capability?
2. Can an existing component already provide it?
3. Does it materially contribute to infrastructure-engineering learning or lab operation?
4. Is the additional operational and recovery complexity justified?

If those questions do not produce a clear case, record the idea for later rather than deploying it.

## Completion criteria

A workstream is complete when its **purpose, design, implementation, validation, limitations, recovery considerations and lessons learned** are documented.

An incomplete or failed experiment is still valuable portfolio evidence when accurately explained.

The objective is not to maximise the number of services in Astra. The objective is to demonstrate that the environment can be **understood, automated, operated, troubleshot and recovered**.