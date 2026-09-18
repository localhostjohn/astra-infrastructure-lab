# Intune Rollout and Validation

The Astra baseline uses **controlled rollout and evidence** rather than enabling a policy tenant-wide as soon as it has been designed.

This document is the default change pattern for Conditional Access, compliance, endpoint security, configuration, application and update policies.

## Deployment rings

Use deployment groups that describe the role of the device or user in testing:

```text
ASTRA-GRP-INTUNE-PILOT
ASTRA-GRP-INTUNE-MANAGED-WINDOWS
ASTRA-GRP-INTUNE-ADMINS
ASTRA-GRP-INTUNE-BYOD-MOBILE
ASTRA-GRP-INTUNE-EXCEPTIONS-<PURPOSE>
```

A pilot group should remain deliberately small enough that a failed policy cannot remove every recovery path.

## Standard rollout flow

### 1. Define the requirement

Record:

- what problem the policy addresses;
- what users/devices/apps are in scope;
- what is intentionally out of scope;
- prerequisites and licensing;
- likely failure modes;
- rollback route.

### 2. Build the policy without broad assignment

Create the policy using the Astra naming convention and confirm every configured value before assigning it.

Where possible, keep the initial policy disabled, report-only or audit-only until the configuration has been peer/self-reviewed.

### 3. Confirm recovery

Before changing access, authentication, encryption, local administrator or destructive device controls, verify the recovery path.

Examples include:

- a tested emergency-access account for Conditional Access work;
- a disposable test device or snapshot;
- BitLocker recovery material;
- an alternative administrator session;
- a documented way to remove the assignment.

### 4. Run report-only or audit mode

Use report-only/audit capability when the control provides it.

Review the resulting events for:

- unexpected users or devices;
- legitimate applications that would fail;
- conflicting settings;
- false assumptions about device state;
- service identities or automation that need explicit design.

### 5. Assign a pilot

Move the policy to a named pilot group.

Do not add the broad managed-device group at the same time.

### 6. Perform positive and negative tests

For each policy, test both the expected success path and at least one expected failure/deny path.

Example:

| Test | Expected |
| --- | --- |
| Managed compliant device signs in | Allowed |
| Deliberately non-compliant test device signs in | Blocked or remediated according to design |
| Privileged account uses approved strong auth | Allowed |
| Privileged account attempts weaker auth | Does not satisfy the privileged policy |

### 7. Review logs and effective state

Do not rely only on the user-visible result.

Depending on the control, inspect:

- Entra sign-in logs;
- Conditional Access evaluation;
- Intune device configuration status;
- compliance state;
- endpoint-security reporting;
- Windows Event Viewer;
- `dsregcmd /status` where relevant;
- `Get-BitLockerVolume`;
- Defender status;
- effective browser or MDM policy pages.

Only record outputs that are safe to publish.

### 8. Exercise rollback

Before broader deployment, prove that the documented rollback is usable.

For a policy assignment this may be removing the pilot assignment. For a device configuration it may require policy reversal, exclusion or restoration from a disposable test snapshot.

### 9. Broaden scope

Expand only after the pilot result matches the written acceptance criteria.

A broader assignment should be a separate change, not an undocumented edit to the original pilot.

### 10. Capture evidence and review date

Create a sanitised evidence note containing:

- policy ID and revision;
- date;
- target group;
- test identity type;
- device type and management state;
- expected result;
- observed result;
- log/report evidence;
- rollback result;
- limitations;
- next review date.

## Conditional Access acceptance template

```markdown
# <date> - <policy ID>

## Objective
What access decision is being tested?

## Scope
Test user:
Test device:
Target app:
Include group:
Exclude group:

## Policy state
Report-only / On / Off:

## Positive test
Expected:
Observed:
Result: PASS / FAIL

## Negative test
Expected:
Observed:
Result: PASS / FAIL

## Sign-in log
Conditional Access result:
Authentication requirement:
Device state:

## Rollback
Method:
Tested: Yes / No
Observed result:

## Limitations
Anything not proven by this test.

## Sanitisation
Confirm no tenant ID, real UPN, device serial, IP requiring redaction, token, secret or recovery key is included.
```

## Intune device-policy acceptance template

```markdown
# <date> - <policy ID>

## Objective
What endpoint state should this policy create?

## Test device
Platform:
Join/enrolment state:
Assignment group:

## Before
Relevant setting/state:

## After
Intune reports:
Local device reports:
Expected:
Observed:
Result: PASS / FAIL

## Conflict check
Any Intune conflict/error:
Any overlapping policy:

## Recovery / rollback
Action:
Observed result:

## Limitations
Anything still untested.
```

## Failure handling

A failed test should result in one of four outcomes:

1. **Fix and retest** — the design is correct but implementation was wrong.
2. **Add a documented exception** — a legitimate dependency cannot yet meet the baseline.
3. **Redesign** — the policy produces an unacceptable side effect.
4. **Pause** — licensing, platform support, cost or another dependency prevents meaningful validation.

Do not convert an unexplained failure into a permanent exclusion.

## Evidence naming

Recommended evidence path:

```text
evidence/YYYY-MM-DD-intune-<policy-id>-<short-description>.md
```

Example:

```text
evidence/2026-10-05-intune-astra-ca-01-legacy-auth-validation.md
```

## Future automation

Once several policies have been manually validated, the next engineering step is to explore repeatable policy inventory and configuration through Microsoft Graph/PowerShell.

Automation should begin with **read-only export and drift detection**, then move to controlled creation/update only after:

- stable policy IDs and naming exist;
- secrets are externalised;
- configuration is parameterised;
- a dry-run or diff is available;
- rollback is understood;
- the lab tenant can be rebuilt without relying on unpublished state.

The aim is not to automate uncertainty. The aim is to automate a baseline that has already been understood and tested.

