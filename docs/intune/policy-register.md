# Astra Intune Policy Register

This register is the single high-level catalogue for the Astra Intune baseline. **All controls are design-stage unless a later evidence note explicitly records successful lab validation.**

Status values:

- **Design** — documented but not yet implemented.
- **Pilot** — assigned only to a bounded test scope.
- **Validated** — tested with recorded evidence.
- **Paused** — implementation intentionally stopped because of cost, licensing, compatibility or another dependency.
- **Retired** — no longer part of the baseline.

## Conditional Access

| ID | Policy | Scope | Initial rollout | Status |
| --- | --- | --- | --- | --- |
| ASTRA-CA-01 | Block legacy authentication client types | Users/admins | Report-only → pilot → enforce | Design |
| ASTRA-CA-02 | Require MFA for standard users | Standard users | Pilot → enforce | Design |
| ASTRA-CA-03 | Require phishing-resistant auth for admins | Privileged identities | Pilot → enforce | Design |
| ASTRA-CA-04 | Protect security-info registration | Users registering methods | Pilot → enforce | Design |
| ASTRA-CA-05 | Require managed/compliant Windows | Managed Windows users | Report-only → pilot | Design |
| ASTRA-CA-06 | Block unsupported platforms | Unsupported OS families | Report-only → enforce | Design |
| ASTRA-CA-07 | Standard-user session baseline | Standard users | Pilot | Design |
| ASTRA-CA-08 | Privileged session baseline | Admins | Pilot | Design |
| ASTRA-CA-09 | Windows token protection | Supported Windows clients | Report-only first | Design |
| ASTRA-CA-10 | Block device-code flow | Users/apps without approved need | Report-only → enforce | Design |
| ASTRA-CA-11 | Block authentication transfer | Supported sign-in flows | Report-only/pilot | Design |
| ASTRA-CA-12 | Emergency-access design | Recovery identities | Separate validation | Design |
| ASTRA-CA-BYOD-01 | Restrict unmanaged Windows to controlled web access | BYOD Windows | Pilot | Design |
| ASTRA-CA-BYOD-02 | Require protected mobile apps | BYOD iOS/Android | Pilot | Design |
| ASTRA-CA-BYOD-03 | Shorter BYOD sessions | BYOD users | Pilot | Design |

## Enrolment and compliance

| ID | Policy | Scope | Initial rollout | Status |
| --- | --- | --- | --- | --- |
| ASTRA-ENR-01 | Windows enrolment restrictions | Device enrolment | Test user/device | Design |
| ASTRA-ENR-02 | Device naming/categories | Managed devices | Pilot | Design |
| ASTRA-COMP-01 | Windows compliance baseline | Managed Windows | Pilot | Design |
| ASTRA-COMP-02 | Compliance grace period | Managed Windows | Pilot | Design |

## Endpoint security

| ID | Policy | Scope | Initial rollout | Status |
| --- | --- | --- | --- | --- |
| ASTRA-SEC-01 | Reviewed Windows security baseline | Managed Windows | Pilot | Design |
| ASTRA-SEC-02 | Defender Antivirus | Managed Windows | Pilot | Design |
| ASTRA-SEC-03 | Windows Firewall | Managed Windows | Pilot | Design |
| ASTRA-SEC-04 | BitLocker | Supported managed Windows | Pilot | Design |
| ASTRA-SEC-05 | Attack Surface Reduction | Managed Windows | Audit → pilot block | Design |
| ASTRA-SEC-06 | Account protection / Windows LAPS | Managed Windows | Pilot | Design |
| ASTRA-SEC-07 | Windows Hello for Business | Managed Windows users | Pilot | Design |

## Configuration, updates and apps

| ID | Policy | Scope | Initial rollout | Status |
| --- | --- | --- | --- | --- |
| ASTRA-CFG-01 | Edge enterprise settings | Managed Windows | Pilot | Design |
| ASTRA-CFG-02 | OneDrive Known Folder Move | Selected test users | Optional pilot | Design |
| ASTRA-UPD-01 | Windows Update pilot ring | Pilot devices | Pilot | Design |
| ASTRA-UPD-02 | Windows Update broad ring | Managed Windows | After pilot | Design |
| ASTRA-UPD-03 | Feature update control | Managed Windows | Pilot → broad | Design |
| ASTRA-APP-01 | Core application deployment | Managed Windows | Pilot | Design |
| ASTRA-APP-02 | Application inventory review | Managed Windows | Read-only review | Design |

## BYOD / MAM

| ID | Policy | Scope | Initial rollout | Status |
| --- | --- | --- | --- | --- |
| ASTRA-MAM-01 | App Protection Policy | BYOD mobile | Test user/device | Design |
| ASTRA-MAM-02 | Mobile CA integration | BYOD mobile | Pilot | Design |

## Device lifecycle

| ID | Policy | Scope | Initial rollout | Status |
| --- | --- | --- | --- | --- |
| ASTRA-DEV-01 | Inactive-device review | Managed device inventory | Manual review | Design |
| ASTRA-DEV-02 | Retire/wipe recovery runbook | Disposable test device | Manual validation | Design |

## Policy ownership fields

When a policy moves beyond design, its evidence record should include:

| Field | Required content |
| --- | --- |
| Policy ID | Stable Astra ID |
| Display name | Actual tenant policy name |
| Owner | Lab administrator / workstream owner |
| Purpose | The risk or operational requirement addressed |
| Prerequisites | Licence, platform, identity and device dependencies |
| Assignment | Include/exclude groups |
| Deployment state | Design, report-only/audit, pilot, validated, paused or retired |
| Last tested | Date of most recent validation |
| Rollback | Exact safe reversal route |
| Evidence | Link to sanitised evidence note |
| Exceptions | Named exception record and review date |

## Change-control rule

A policy is not considered part of the **validated Astra baseline** merely because it exists in Intune. It becomes validated only when:

1. the intended assignment is confirmed;
2. a positive test succeeds;
3. a negative or failure-path test behaves as expected;
4. logs support the observed result;
5. rollback has been defined;
6. public evidence has been sanitised.

