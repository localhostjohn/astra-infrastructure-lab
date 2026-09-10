# Infrastructure Learning Roadmap

This roadmap is a learning plan, not a list of production commitments. Dates and completion claims will be added only when work has been carried out and validated.

## 1. Establish a reliable baseline

Record a sanitised inventory of lab roles, dependencies and software versions. Verify access, DNS, time synchronisation, disk space and backup configuration. Create a simple change log and document recovery paths before further restructuring.

**Evidence:** Architecture revision, baseline checks and a recovery plan.

## 2. Strengthen Windows and identity administration

Revisit delegated administration, GPO scope, service-account permissions and directory health. Add read-only PowerShell checks with error handling and documented prerequisites. Validate both successful and denied actions in disposable lab accounts.

**Evidence:** Sanitised scripts, test matrix and troubleshooting notes.

## 3. Networking and segmentation

Design non-overlapping subnets, management access and VLAN routing in a simulator or isolated virtual lab. Define allowed flows before choosing switching/firewall hardware. Test inter-VLAN access, DNS, DHCP, management restrictions and rollback. Do not claim physical VLAN deployment until it is implemented and tested.

**Evidence:** Reference topology, addressing plan, configuration excerpts and connectivity/deny tests.

## 4. Hybrid identity

Review Microsoft Entra prerequisites, UPN design, synchronisation scope, licensing, security and rollback. Use dedicated test identities and validate the lifecycle before extending the design. Keep the existing directory separate from production or employer tenants.

**Evidence:** Design decisions, sync scope and end-to-end identity tests.

## 5. Infrastructure as code — Astra SOC Bicep project

Use the planned `astra-soc` Azure Ubuntu VM as the first focused Infrastructure-as-Code project. Start with Azure Bicep rather than attempting Terraform and Bicep simultaneously. Keep the initial deployment small enough to understand each resource and dependency.

The first iteration should define the SOC network, security subnet, Network Security Group, network interface and Ubuntu VM with SSH public-key authentication. Values such as location, address ranges, VM size and administrator username should be parameterised. Deployment validation, repeatability and a documented teardown are part of the exercise.

Once the base deployment has been validated, refactor suitable resources into modules and add cost/security controls deliberately rather than expanding the template prematurely.

See [Astra SOC](soc/README.md) and the [Astra SOC Bicep workspace](../infrastructure/azure/astra-soc/README.md).

**Evidence:** Reviewed Bicep templates, validation output, sanitised deployment evidence, repeat-deployment notes and cleanup record.

## 6. Astra SOC security monitoring

Build the dedicated Astra SOC workstream using the Bicep-provisioned Ubuntu host for heavier SIEM components while retaining lightweight monitoring services on the home-lab infrastructure. Deploy the container platform first, then Wazuh, endpoint telemetry and controlled lab-only test scenarios.

Do not describe detections as validated until the expected event has been generated in an authorised test endpoint and the observed result has been captured.

**Evidence:** Architecture decisions, Docker/Wazuh deployment records, endpoint onboarding, controlled-event test matrix, alert evidence and recovery notes.

## 7. Operations and recovery

Define monitoring checks and alerts, document container updates, and perform a full backup/restore test with disposable data. Record failure scenarios and recovery time. Consider a separate backup destination and restore automation only after the basic workflow is proven.

**Evidence:** Sanitised monitoring test, restore log, checksums and runbook.

## Completion criteria

A workstream is complete when its purpose, design, implementation, validation, limitations and lessons learned are documented. An incomplete or failed experiment is still valuable portfolio evidence when accurately explained.
