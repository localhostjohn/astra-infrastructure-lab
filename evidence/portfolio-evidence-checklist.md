# Infrastructure Portfolio Evidence Checklist and Controlled Outage Plan

**Reviewed:** 9 September 2026  
**Scope:** Personal Astra lab only  
**Outage exercise status:** Not run — this document is a plan, not a test result.

## Portfolio summary

The latest recorded work demonstrates scheduled encrypted backups, non-destructive retention review, isolated file recovery and tested PowerShell inventory behaviour. These are separate controls: successful backup execution does not prove complete application recovery, and mocked inventory tests do not establish live directory health.

The Pi evidence was recorded on 9 September; the AD unit-test evidence was recorded on 8 September. Results below come from the maintainer's sanitised records, not an independently repeated test run.

## Evidence checklist

Checked items mean that a supporting result is recorded in this repository. Unchecked items remain outstanding; configuration alone is not a passed test.

### Raspberry Pi backup and recovery

Source: [Backup and Recovery Validation](2026-09-09-raspberry-pi-backup-recovery.md).

- [x] **PI-05 — Scheduled backup:** successful 02:00 BST run on 9 September; snapshot saved and service completed successfully. Record includes 620 source files and approximately 103.971 MiB.
- [x] **PI-06 — Retention dry run:** successful 03:00 BST policy evaluation; seven daily, four weekly and six monthly snapshots plus baseline-tagged snapshots; one candidate for removal and no snapshots deleted.
- [x] **PI-08 — Isolated file restore:** selected disposable 36-byte file restored into a separate temporary directory; original/restored SHA-256 digests matched and byte comparison passed.
- [ ] **PI-07 — Repository integrity:** capture an actual completed check, exit status, date, duration and limitations. The enabled timer and reviewed configuration are not a successful check result.
- [ ] **Current baseline:** record OS/kernel, Docker and relevant application versions, container health, free storage and private management connectivity.
- [ ] **Application-level recovery:** restore a selected application's data and configuration into an isolated instance; validate application behaviour and record elapsed recovery time. Do not overwrite live volumes.
- [ ] **Recovery readiness:** privately confirm backup scope, recovery-key availability and required dependencies. Publish only a sanitised summary.
- [ ] **Recovery objectives:** define acceptable recovery time and data loss for the selected lab service, then compare a measured application recovery against those targets.

### Active Directory inventory automation

Source: [AD Inventory Unit-Test Evidence](2026-09-08-ad-inventory-unit-tests.md).

- [x] **Local mocked tests:** six tests passed, zero failed with Pester 5.9.1; reported duration 1.54 seconds.
- [x] **Coverage documented:** inventory structure, explicit server selection, replication-failure reporting, individual query errors, opt-in JSON output/overwrite protection, and a static mutation/command-execution check.
- [ ] **Live Astra execution:** record a read-only run against the authorised lab, including environment versions, successful queries, errors and limitations. Keep raw inventory private.
- [ ] **Optional replication query:** capture the actual result separately; an empty failure list is not a comprehensive AD health assessment.
- [ ] **CI evidence:** link a completed workflow run and its actual outcome before claiming CI passed. Local Pester results are not CI results.

### Monitoring and outage evidence

- [ ] Select one disposable, non-essential container with a simple monitored endpoint.
- [ ] Record healthy baseline, monitor settings and expected detection/recovery behaviour.
- [ ] Verify rollback access and agree a bounded test window.
- [ ] Observe a real transition from healthy to down following an intentional stop.
- [ ] Restore the same target and verify endpoint behaviour and monitoring recovery.
- [ ] Record timestamps, measured delays, unexpected behaviour and lessons learned.
- [ ] If notifications are included, capture both delivered down and recovery notifications with secrets redacted; otherwise explicitly mark notification delivery as not tested.

## Next milestone: controlled container outage

**Objective:** demonstrate that monitoring detects loss of a disposable service and returns to healthy after controlled restoration. This tests service availability monitoring and restart recovery, not backup restoration or full-host resilience.

### Scope and safety gate

Use a dedicated test container, not Portainer, Uptime Kuma, DNS filtering, the Docker daemon, Tailscale, SSH, backup services or an AD dependency. Do not reboot or disconnect the Pi, remove volumes, prune containers or change network routing.

Before starting:

- [ ] Resolve and privately record the exact target name/ID, image version, endpoint, current state and restart policy.
- [ ] Confirm that stopping it cannot disrupt household connectivity or another service.
- [ ] Keep the monitoring service running independently of the test container.
- [ ] Confirm that private administrative access works and that the exact target can be started again without relying on the stopped service.
- [ ] Record monitor interval, timeout, retry settings and any alert delay; derive an expected detection window from those settings.
- [ ] Reserve a ten-minute lab test window, with a maximum intentional outage of five minutes. If the expected detection window exceeds five minutes, redesign the test before proceeding.
- [ ] Record at least three consecutive successful checks and verify the endpoint directly.

This document deliberately supplies no generic stop command: confirm the actual disposable target before executing any state-changing command.

### Test sequence and acceptance criteria

| Stage | Action | Evidence and acceptance criterion |
| --- | --- | --- |
| Baseline | Check the disposable endpoint and monitor | Endpoint works; at least three consecutive checks are healthy |
| Inject outage | Stop only the confirmed disposable container | Record stop time and stopped state; direct endpoint check fails |
| Observe detection | Keep the target stopped within the agreed limit | Monitor changes to down within the pre-recorded expected window |
| Restore | Start the same target; preserve its data and configuration | Record start time; verify endpoint response and expected application behaviour |
| Verify recovery | Observe monitoring after restoration | Monitor returns to healthy within the expected window and remains healthy for three checks |
| Close | Check management access and essential services | No unintended service impact; publish sanitised results and follow-up actions |

Restore immediately if essential services are affected, monitoring becomes unavailable, the wrong target was selected, or the maximum outage time is reached. A missing down transition must be recorded as a failure, not hidden by changing thresholds after the event. Investigate and schedule a separate retest.

If restoration fails, keep scope limited to the disposable target, record the failure and stop further fault injection. Do not delete volumes or restart the host as an improvised recovery step.

### Result record — complete after execution

| Field | Value |
| --- | --- |
| Test ID | MON-01-OUTAGE-01 |
| Status | Not run |
| Date/time zone and operator | To record |
| Sanitised target and versions | To record |
| Monitor interval / timeout / retries | To record |
| Expected detection / recovery windows | To define before testing |
| Stop time / first direct failure | To record |
| Monitor down time | To record |
| Restart time / first successful endpoint response | To record |
| Monitor recovery time | To record |
| Detection delay | Monitor down time minus stop time |
| Observed service unavailability | First successful response minus first observed failure; approximate and dependent on probe frequency |
| Monitoring recovery delay | Monitor recovery time minus first successful endpoint response |
| Notifications | Not tested unless explicitly included and evidenced |
| Unintended impact / corrective action | To record |
| Evidence links / lessons / retest | To record |

A monitor on the same Pi cannot demonstrate detection of a total Pi outage while that monitor is also offline. Independent monitoring is a separate future exercise. Restarting a container also does not demonstrate restoration from backup or achievement of an application recovery objective.

## Publication review

- [ ] Use only personal-lab or explicitly fictional examples; no employer configuration, identities or screenshots.
- [ ] Remove credentials, webhook URLs, tokens, SSH keys, environment-file contents, private endpoints and identifying addresses.
- [ ] Review screenshot metadata, browser tabs, terminal scrollback and account names.
- [ ] Label transcriptions and recreated illustrations accurately; preserve genuine failures and limitations.
- [ ] Link each passed claim to a dated evidence record; leave unperformed checks unchecked.
- [ ] Reconcile summary/register wording when new results are added. The older general [validation register](../docs/validation.md) still contains pre-evidence statuses; use the dated source records above for these specific results.

See [Security and Publication](../SECURITY.md) and the [Pi operations runbook](../docs/raspberry-pi-operations.md).
