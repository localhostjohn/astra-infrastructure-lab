# Group Policy Design, Validation and Rollback

**Status:** Historical GPO exercises recorded; effective-policy test evidence still to capture.

## Recorded exercises

The existing [Active Directory notes](../active-directory.md) describe removable-storage restriction/exception and shared-drive GPO exercises. They do **not** contain verified current policy exports or evidence that those GPOs still apply.

## Design principles

1. State the business/test requirement and choose **user** versus **computer** policy.
2. Identify the OU link, inheritance, enforcement and applicable security/WMI filtering.
3. Use dedicated lab groups and disposable identities rather than real users.
4. Record intended policy precedence and exception scope.
5. Pilot with a test client; validate an expected permit and expected deny.
6. Record rollback before enabling restrictions and verify restoration afterwards.

## GPO validation examples

In an authorised test client session:

```powershell
gpresult /r
gpresult /h "$env:TEMP\astra-gpo-report.html"
```

On a suitable administrative host:

```powershell
Import-Module GroupPolicy
Get-GPO -All | Select-Object DisplayName, Id, GpoStatus, ModificationTime
```

`gpresult` reports effective policy for the specified user/computer context; simply seeing a GPO linked does not prove its settings applied. Treat the local HTML report as sensitive and do not upload it unredacted.

## Test and evidence register

| Scenario | Expected | Actual | Status |
| --- | --- | --- | --- |
| Removable storage restricted user/device | Access blocked as designed | Pending | Not retested |
| Exception identity/device | Access permitted only as designed | Pending | Not retested |
| Shared-drive policy | Intended mapping available in intended context | Pending | Not retested |
| Out-of-scope user/device | Policy does not apply | Pending | Not retested |
| Rollback | Baseline behaviour restored | Pending | Not retested |

**Caution:** An Entra group is not automatically an on-prem AD group for GPO security filtering. Confirm actual identities and group scope.

## Troubleshooting notes

Check OU location, link status, inheritance, security filtering, WMI filters, replication (where relevant), DNS, time and the GroupPolicy operational log. Use `gpresult` and Event Viewer to diagnose the effective state before changing scope.

## Follow-up

Capture the original requirement, redacted configuration, expected/actual outcomes, screenshots if safe, event IDs, rollback and a dated sign-off in [validation and recovery](validation-and-recovery.md).
