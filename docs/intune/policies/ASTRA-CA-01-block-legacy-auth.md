# ASTRA-CA-01 — Block Legacy Authentication

**Policy ID:** ASTRA-CA-01  
**Display name:** `ASTRA-CA-01-BLOCK-LEGACY-AUTH`  
**Current repository status:** Design  
**Target rollout:** Report-only → pilot review → enforce only after validation

## Objective

Reduce exposure to legacy authentication paths by blocking legacy client types that do not participate in the modern authentication controls expected by the Astra tenant.

This is the first Conditional Access policy chosen for implementation because it is narrow, observable in sign-in logs and suitable for a report-only-first deployment.

## Source and implementation basis

The Astra policy is inspired by the layered Conditional Access approach in *My Conditional Access Baseline for Microsoft 365 Business Premium*, where blocking legacy authentication is placed at the start of the managed-device baseline.

The actual implementation steps below are based on current Microsoft Entra documentation rather than copied from the source guide.

Microsoft reference:

- https://learn.microsoft.com/entra/identity/conditional-access/policy-block-legacy-authentication
- https://learn.microsoft.com/entra/identity/conditional-access/concept-conditional-access-report-only

## Prerequisites

Before creating the policy:

- confirm you have a role that can create Conditional Access policies;
- confirm at least one emergency-access/recovery route exists and is not dependent on the new policy;
- identify the Astra test/pilot account or group;
- make sure no employer or production tenant is being used;
- be prepared to review Entra sign-in logs before enforcement.

## Proposed Conditional Access configuration

### Name

```text
ASTRA-CA-01-BLOCK-LEGACY-AUTH
```

### Users or workload identities

For the first Astra implementation:

- **Include:** the dedicated Astra pilot/test user or pilot group.
- **Exclude:** emergency-access/recovery identities where appropriate.

Do not start with all users while the policy is still being validated.

### Target resources

- **Include:** All resources.

### Conditions → Client apps

Set **Configure** to **Yes**.

Select only:

- **Exchange ActiveSync clients**
- **Other clients**

These are the current Microsoft-documented client app selections for the legacy-authentication blocking policy.

### Access controls → Grant

- **Block access**

### Enable policy

- **Report-only**

Do not switch the policy to **On** during the initial creation.

## Initial validation

After the policy exists in report-only mode:

1. Sign in normally from a supported modern browser or Microsoft 365 client using the pilot identity.
2. Open **Entra ID → Monitoring & health → Sign-in logs**.
3. Open the relevant sign-in.
4. Review the **Conditional Access** evaluation and confirm how `ASTRA-CA-01-BLOCK-LEGACY-AUTH` was evaluated.
5. Filter/search sign-in activity for legacy client types before considering enforcement.
6. Record whether any legitimate Astra workload still depends on a legacy client.

A normal modern sign-in is expected not to be blocked by this policy because its client-app condition should not match the legacy-client selections.

## Negative-path validation

The goal is to prove that a sign-in matching the selected legacy client conditions would be reported as blocked by the policy if it were enabled.

Do not install unsafe or obsolete software purely to manufacture a legacy sign-in. Prefer existing test telemetry or a safe, controlled test method if one is available.

If no legitimate legacy-authentication event exists in the Astra lab, record that limitation rather than inventing a successful negative test.

## Acceptance criteria

The policy can move from **Design** to **Pilot** when:

- the Conditional Access policy exists with the correct Astra name;
- it is in Report-only mode;
- its scope is limited to the intended test identity/group;
- All resources is selected;
- only Exchange ActiveSync clients and Other clients are selected under Client apps;
- Block access is selected;
- a recovery path has been checked;
- at least one modern sign-in has been reviewed in the sign-in logs.

The policy can move toward **Validated** only after:

- report-only results have been reviewed for an appropriate observation window;
- any legacy-authentication events have been explained;
- exceptions, if any, have an owner/reason/review date;
- rollback is documented;
- evidence has been sanitised and committed.

## Rollback

While the policy remains in Report-only mode, it does not enforce the block.

If the policy is later enabled and causes an unexpected impact:

1. disable the policy or return it to Report-only;
2. confirm the affected sign-in succeeds again;
3. review the matching client-app condition in the sign-in logs;
4. document the dependency before deciding whether to redesign or create a time-bound exception.

## Evidence to capture

Create a future evidence record such as:

```text
evidence/YYYY-MM-DD-intune-astra-ca-01-legacy-auth-validation.md
```

Capture only sanitised evidence:

- policy display name;
- report-only state;
- assignment type;
- selected target resources;
- selected client-app conditions;
- grant control;
- sign-in log Conditional Access result;
- observed modern-client behaviour;
- any legacy-client events;
- rollback result when enforcement is eventually tested.

Do **not** publish tenant IDs, real UPNs, device identifiers, IP addresses that should remain private, tokens, credentials or recovery-account details.

## Implementation record

| Field | Value |
| --- | --- |
| Policy created in tenant | Not yet recorded |
| Report-only enabled | Not yet recorded |
| Pilot assignment confirmed | Not yet recorded |
| Modern sign-in reviewed | Not yet recorded |
| Legacy sign-in evidence reviewed | Not yet recorded |
| Enforcement decision | Not yet made |
| Evidence file | Not yet created |

