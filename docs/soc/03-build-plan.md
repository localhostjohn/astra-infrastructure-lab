# Astra SOC Build Plan

This plan tracks the implementation sequence for Astra SOC. Items remain unchecked until they have been completed and suitable evidence has been captured.

## Phase 1 — Azure foundation

- [ ] Confirm Azure region and VM SKU
- [ ] Create the Bicep project structure
- [ ] Define resource group deployment parameters
- [ ] Define virtual network and `snet-security`
- [ ] Define `nsg-astra-soc`
- [ ] Define `nic-astra-soc`
- [ ] Define Ubuntu VM `astra-soc`
- [ ] Configure SSH public-key authentication
- [ ] Validate the Bicep template
- [ ] Deploy the foundation
- [ ] Capture sanitised deployment evidence

## Phase 2 — Ubuntu baseline

- [ ] Confirm hostname and OS version
- [ ] Apply operating-system updates
- [ ] Confirm time synchronisation
- [ ] Configure/verify host firewall policy
- [ ] Install Tailscale
- [ ] Validate private management access
- [ ] Remove or restrict temporary public SSH access
- [ ] Record baseline CPU, memory and disk capacity

## Phase 3 — Container platform

- [ ] Install Docker Engine from the official repository
- [ ] Install Docker Compose plugin
- [ ] Validate Docker with a disposable container
- [ ] Define persistent storage paths
- [ ] Configure log rotation where appropriate
- [ ] Document container update procedure
- [ ] Record Docker version and validation evidence

## Phase 4 — Wazuh

- [ ] Review current Wazuh Docker prerequisites
- [ ] Configure required Linux kernel settings
- [ ] Deploy Wazuh Manager
- [ ] Deploy Wazuh Indexer
- [ ] Deploy Wazuh Dashboard
- [ ] Confirm containers are healthy
- [ ] Confirm persistent data survives a controlled restart
- [ ] Restrict dashboard access to the intended management path
- [ ] Store credentials outside version control

## Phase 5 — Endpoint onboarding

- [ ] Add a disposable Astra Windows test endpoint
- [ ] Add the Astra lab Windows Server where appropriate
- [ ] Evaluate Raspberry Pi agent/telemetry requirements
- [ ] Confirm endpoint-to-manager communication
- [ ] Document agent removal and recovery procedure

## Phase 6 — Controlled security tests

- [ ] Failed login test
- [ ] Account lockout test
- [ ] Disposable local administrator creation
- [ ] Test PowerShell execution
- [ ] Stop/restart a disposable service
- [ ] Authorised lab-only network scan
- [ ] New network-device detection
- [ ] Record expected versus observed results

## Phase 7 — Operations and observability

- [ ] Define service-health checks
- [ ] Add SOC health monitoring to the existing observability workstream
- [ ] Configure alert routing for selected events
- [ ] Test an alert end to end
- [ ] Document restart order and dependency recovery
- [ ] Add backup requirements for Wazuh configuration and persistent data

## Phase 8 — AI-assisted analysis

Only begin this phase after the core SIEM platform is stable and testable.

- [ ] Define the `astra-ai-analyst` threat-analysis use case
- [ ] Define which event fields may be sent to an AI service
- [ ] Remove or mask sensitive fields before external processing
- [ ] Build a small containerised analysis service
- [ ] Add event summarisation
- [ ] Add MITRE ATT&CK enrichment where appropriate
- [ ] Test false-positive and incomplete-context behaviour
- [ ] Ensure the AI layer remains advisory rather than an automated remediation authority

## Evidence requirements

For each phase, capture enough evidence to prove what was actually implemented without exposing secrets or employer information. Useful evidence may include:

- Sanitised Azure resource views
- `az deployment` validation output
- Bicep source files
- Linux version and service status output
- Docker container health output
- Wazuh dashboard screenshots using fictional Astra data
- Controlled test logs
- Recovery/restart results
- Lessons learned

## Definition of done

A phase is complete when the purpose, design, implementation, validation, limitations and rollback/recovery considerations are documented. A failed experiment can still be useful evidence when accurately recorded rather than hidden.
