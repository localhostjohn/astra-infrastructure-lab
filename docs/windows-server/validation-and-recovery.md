# Windows Server, AD DS and Virtualisation — Validation & Recovery

**Status:** Documentation/test plan prepared on 2026-11-16. **No new live test executed as part of this documentation update.**

## Evidence discipline

Every result must record environment (VirtualBox or Azure), date/time and time zone, operator, objective, prerequisites, non-sensitive command/method, expected outcome, actual outcome, pass/fail/not-run, rollback and a link to sanitised evidence. Do not promote a plan, screenshot or mocked test to a passed live test.

## Baseline register

| ID | Environment | Check | Status |
| --- | --- | --- | --- |
| WIN-VB-01 | VirtualBox | Host/hypervisor version and VM inventory | Not run |
| WIN-VB-02 | VirtualBox | Virtual networking and guest isolation | Not run |
| WIN-VB-03 | VirtualBox | Windows Server roles and services | Not run |
| WIN-AZ-01 | Azure | VM inventory, size, state and access path | Not run |
| WIN-AZ-02 | Azure | VNet DNS, NSG and administrative exposure | Not run |
| WIN-AD-01 | Each applicable lab | Domain/DC enumeration, DNS SRV and DCDIAG | Not run |
| WIN-AD-02 | Each applicable lab | Disposable domain-client sign-in | Not run |
| WIN-GPO-01 | Each applicable lab | Applied restriction + allowed exception | Not run |
| WIN-SEC-01 | Each applicable lab | Delegated allowed + denied actions | Not run |
| WIN-SA-01 | Applicable lab | Scheduled task runs under intended identity | Not run |
| WIN-REC-01 | Disposable lab | Defined recovery and rollback exercise | Not run |

Historical AD DS and service-account exercises are described in [active-directory.md](../active-directory.md). Six **mocked Pester tests** are documented at [AD inventory unit-test evidence](../../evidence/2026-09-08-ad-inventory-unit-tests.md); they are separate from these live checks.

## Read-only baseline collection

On a Windows Server VM:

```powershell
$PSVersionTable.PSVersion
Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, OsBuildNumber
Get-WindowsFeature AD-Domain-Services, DNS
Get-NetIPConfiguration
Get-Service NTDS, DNS -ErrorAction SilentlyContinue
```

On a host with AD administrative tools and appropriate permissions:

```powershell
Import-Module ActiveDirectory
Get-ADDomain
Get-ADDomainController -Filter *
Get-ADReplicationFailure -Target * -Scope Domain -ErrorAction SilentlyContinue
```

Replication results are meaningful only in the context of a confirmed topology. A single-DC environment cannot demonstrate multi-DC replication.

Use `dcdiag /test:dns` and `gpresult /r` selectively as appropriate. Sanitise outputs before publishing.

## Recovery design and safety

**VirtualBox:** A snapshot is a temporary rollback mechanism, not a backup. Record the VM backup location, storage dependency and restore scope. Test with a disposable server; do not roll back a live or multi-DC AD environment casually.

**Azure:** Confirm backup method, storage scope, VM power state and cost. Do not equate recovery-point creation with a tested recoverable domain controller. Prefer a separated disposable restore target for validation and consult supported AD DS recovery procedures.

For any domain controller, review authoritative/non-authoritative restore requirements, directory database consistency, SYSVOL, DNS and post-restore authentication before selecting a recovery method. Do not restore a production controller as a learning exercise.

## Runbook: safe controlled failure

1. Select a **non-critical disposable VM or test client**, not a live domain controller serving other clients.
2. Confirm backup/recovery path and admin access independently of the target.
3. Capture a healthy baseline and expected failure/impact.
4. Perform one bounded change (e.g. disable a disposable client's test DNS setting), documenting the exact change privately.
5. Observe resolution/sign-in failure without expanding the outage.
6. Restore the original setting; verify recovery, DNS and authentication.
7. Record timestamps, actual results, unexpected effects and improvement actions.

This sequence is an **example** and has not been executed here.

## Evidence record template

```markdown
# WIN-<ID> — <Test title>
- Date/time zone:
- Lab/environment:
- Build/version (sanitised):
- Goal and acceptance criterion:
- Preconditions and safety/rollback gate:
- Method / non-sensitive commands:
- Expected result:
- Observed result:
- Status: PASS / FAIL / NOT RUN / BLOCKED
- Sanitised evidence link:
- Remediation, retest and lessons:
```

## Sign-off

- [x] Documentation and safe, read-only checks prepared.
- [ ] Local VirtualBox current-state inventory independently captured.
- [ ] Azure VM current-state inventory independently captured.
- [ ] Live AD DS, DNS, GPO, delegation and service-account checks completed.
- [ ] One bounded fault and recovery exercise completed.
- [ ] Results, dates and evidence links reviewed and published safely.

**Portfolio conclusion:** The current artefacts provide a traceable implementation history and a repeatable validation plan. They do **not** yet evidence a presently healthy or production-ready Windows infrastructure.
