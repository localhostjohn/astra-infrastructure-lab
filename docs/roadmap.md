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

## 5. Intune and endpoint management

Build the Astra Intune baseline in a controlled lab scope. Start with policy inventory and naming, then validate Conditional Access, Windows compliance, endpoint security, update rings and selected application-management controls through pilot groups. Treat BYOD as a separate extension rather than weakening the managed-device baseline. Capture positive and negative tests, conflicts, rollback and sanitised evidence before marking any control as validated.

**Evidence:** Policy register, report-only/audit results, pilot test records, effective device state, rollback notes and sanitised screenshots or exports.

## 6. Infrastructure as code

**Current status:** Bicep has been selected as the present Azure IaC path. The first small network foundation is implemented on the open `feature/bicep-network-foundation` branch in [PR #5](https://github.com/localhostjohn/astra-infrastructure-lab/pull/5), covering a VNet, workload subnet, NSG, parameters and outputs. It is not yet treated as completed evidence because deployment/repeatability validation is still pending.

Continue with the small isolated Azure deployment using version control, parameterised configuration, `what-if`, deployment validation and a documented teardown. Avoid live credentials and expensive resources; review cost and permissions before deployment. Only add compute after the networking stage is understood and validated.

**Evidence:** Reviewed Bicep templates, `what-if` output, first deployment, second/repeat deployment behaviour, validation and cleanup record.

## 7. Operations and recovery

Define monitoring checks and alerts, document container updates, and perform a full backup/restore test with disposable data. Record failure scenarios and recovery time. Consider a separate backup destination and restore automation only after the basic workflow is proven.

**Evidence:** Sanitised monitoring test, restore log, checksums and runbook.

## Completion criteria

A workstream is complete when its purpose, design, implementation, validation, limitations and lessons learned are documented. An incomplete or failed experiment is still valuable portfolio evidence when accurately explained.
