# Astra Intune Baseline

This workstream defines a **lab-first Microsoft Intune and Microsoft Entra access baseline** for the Astra environment. It is a design and validation framework rather than a claim that every control is currently deployed.

The baseline is intentionally split into layers so that identity, device compliance, endpoint security, update management and BYOD controls can be tested independently before they are combined.

## Design goals

The Astra baseline is intended to demonstrate:

- least-privilege administration;
- strong authentication for privileged access;
- managed-device and compliance-based access decisions;
- secure Windows endpoint configuration;
- staged deployment with pilot groups and rollback;
- deliberate handling of personal devices rather than accidental BYOD;
- evidence-led validation instead of assuming a successful policy deployment;
- policy naming and documentation that could later support automation through Microsoft Graph, PowerShell or infrastructure-as-code tooling.

## Two operating postures

### Managed-device posture

The default Astra design assumes organisation-owned or lab-managed endpoints. Access to protected services should favour devices that are enrolled, compliant and using supported operating systems.

### BYOD extension

BYOD is treated as an additional layer, not a replacement for the managed-device baseline. Where personal devices are allowed, the design uses more restrictive browser/session controls or Intune App Protection Policies so that organisational data is not treated the same way as data on a managed endpoint.

## Baseline layers

| Layer | Purpose | Document |
| --- | --- | --- |
| Conditional Access | Control who can sign in, from what context and with what authentication strength | [Conditional Access baseline](conditional-access-baseline.md) |
| Device management | Define enrolment, compliance, endpoint security, updates and application controls | [Device management baseline](device-management-baseline.md) |
| Policy register | Track the intended policy catalogue and validation state | [Policy register](policy-register.md) |
| Rollout and evidence | Pilot, validate, monitor, recover and document changes | [Rollout and validation](rollout-validation.md) |

## Astra naming convention

Policies use a predictable prefix and identifier:

```text
ASTRA-<AREA>-<NN>-<SHORT-NAME>
```

Examples:

```text
ASTRA-CA-01-BLOCK-LEGACY-AUTH
ASTRA-COMP-01-WINDOWS-COMPLIANCE
ASTRA-SEC-03-BITLOCKER
ASTRA-UPD-01-WINDOWS-UPDATE-RING
```

The identifier is intended to make screenshots, exports, test evidence and future automation easier to correlate.

## Policy lifecycle

Every control should move through a documented lifecycle rather than being enabled globally without evidence:

```text
Design
  ↓
Prerequisite check
  ↓
Report-only / audit where supported
  ↓
Pilot group
  ↓
Validation
  ↓
Broader lab deployment
  ↓
Evidence captured
  ↓
Periodic review
```

A failed or incompatible test is still useful evidence when the result, impact and rollback are recorded accurately.

## Safety rules

- Never test access-control changes without a documented recovery route.
- Keep emergency-access design separate from ordinary administrator accounts.
- Use dedicated test users and devices before wider assignment.
- Do not publish tenant IDs, real user principal names, device serial numbers, recovery keys, tokens or secrets.
- Treat Microsoft security baselines as a starting point, not a substitute for understanding each configured setting.
- Confirm licensing, platform support and current Microsoft documentation before deploying a control.
- Keep employer configuration, screenshots and internal policy values out of this public repository.

## Status

**Current state: design baseline.**

The files in this directory document the intended Astra approach. Individual controls must be marked as validated only after they have been tested in the Astra lab and supporting evidence has been reviewed for public release.

## Inspiration and references

The structure was inspired in part by the idea of using a layered Conditional Access baseline with a stricter managed-device posture and additional controls when BYOD is permitted. The Astra version expands that concept into a broader Intune endpoint-management baseline and deliberately uses its own naming, rollout model and policy catalogue.

Reference material should be checked against current Microsoft documentation before implementation:

- Microsoft Learn — Microsoft Intune documentation
- Microsoft Learn — Conditional Access
- Microsoft Learn — Intune compliance policies
- Microsoft Learn — Endpoint security policies
- Microsoft Learn — Windows update management
- Microsoft Learn — App Protection Policies

