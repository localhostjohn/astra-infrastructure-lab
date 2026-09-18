# Astra Conditional Access Baseline

This document defines the **proposed Astra Conditional Access policy stack**. It is intentionally written as a lab design: policy names, intent, assignments, exclusions, rollout mode and validation must all be reviewed before enforcement.

The baseline uses a managed-device posture first, then adds separate controls when BYOD is deliberately enabled.

## Principles

1. **Conditional Access is a stack, not a single policy.** Each policy should solve one clearly stated access problem.
2. **Authentication strength should increase with privilege.** Administrator access receives stricter requirements than ordinary user access.
3. **Managed endpoints receive more trust than unmanaged endpoints.** Device compliance is an access signal, not merely an inventory state.
4. **Emergency access must survive policy mistakes.** Recovery accounts are handled separately and monitored.
5. **Report-only and pilot assignments come before broad enforcement** wherever the control supports them.
6. **Exceptions require an owner, reason and review date.** Permanent undocumented exclusions are not part of the baseline.

## Managed-device baseline

### ASTRA-CA-01-BLOCK-LEGACY-AUTH

**Intent:** Prevent sign-ins that use legacy authentication client types which cannot satisfy the modern authentication controls expected by the tenant.

**Target:** Standard users and administrators.

**Initial mode:** Report-only, then enforce after sign-in log review.

**Validation:** Confirm modern Office, browser and supported application sign-ins continue to succeed. Investigate any legacy client events before enforcement.

---

### ASTRA-CA-02-REQUIRE-MFA-USERS

**Intent:** Require MFA for normal user access to protected cloud applications.

**Target:** Standard users.

**Authentication requirement:** Use an approved authentication strength appropriate to the lab. Prefer modern methods over weak fallback methods.

**Validation:** Test expected sign-in, MFA challenge, remembered session behaviour and recovery from a replaced authenticator.

---

### ASTRA-CA-03-PHISHING-RESISTANT-ADMINS

**Intent:** Require phishing-resistant authentication for privileged administrator roles.

**Target:** Dedicated privileged accounts and selected Entra administrative roles.

**Preferred methods:** FIDO2/passkeys or Windows Hello for Business where the tenant and test device support them.

**Validation:** Confirm a privileged account can complete administration with the strong method and that weaker methods do not satisfy the policy.

**Safety gate:** Do not enforce until at least one tested recovery route exists.

---

### ASTRA-CA-04-SECURITY-INFO-REGISTRATION

**Intent:** Protect registration or modification of authentication methods so that possession of a password alone is not sufficient to add a new method.

**Target:** Users registering security information.

**Astra approach:** Require a trusted authentication context. Temporary Access Pass can be used as a controlled onboarding or recovery method where configured and tested.

**Validation:** Test new-user registration, replacement-device registration and help-desk recovery separately.

---

### ASTRA-CA-05-REQUIRE-MANAGED-WINDOWS

**Intent:** Require supported Windows endpoints to meet the Astra managed-device trust requirement before accessing protected services.

**Target:** Managed Windows user population.

**Grant concept:** Require a compliant device and/or an explicitly approved Entra device state according to the final lab design.

**Validation:** Test:
- compliant managed device;
- enrolled but non-compliant device;
- unmanaged Windows device;
- device that has fallen out of compliance.

The final condition must be based on observed sign-in behaviour rather than assumed device-state semantics.

---

### ASTRA-CA-06-BLOCK-UNSUPPORTED-PLATFORMS

**Intent:** Reduce unmanaged access paths by blocking platforms that are outside the Astra support model.

**Target:** Platforms that have no approved lab use case.

**Validation:** Confirm that every blocked platform is genuinely unsupported before enforcement. Document exceptions such as a Linux administration workflow instead of silently weakening the policy.

---

### ASTRA-CA-07-USER-SESSION-BASELINE

**Intent:** Place an explicit reauthentication and browser persistence policy around standard-user sessions rather than relying entirely on defaults.

**Initial lab value:** Start with a longer managed-device interval, then tune from evidence.

**Validation:** Record the actual user experience across browser, Teams and Office clients before broadening scope.

---

### ASTRA-CA-08-ADMIN-SESSION-BASELINE

**Intent:** Use a shorter reauthentication window for privileged sessions than for normal user sessions.

**Target:** Dedicated administrator identities.

**Validation:** Confirm the shorter interval does not break required administrative workflows and that reauthentication uses the expected strong method.

---

### ASTRA-CA-09-WINDOWS-TOKEN-PROTECTION

**Intent:** Bind supported sign-in tokens to the Windows device so that a token copied to a different device cannot simply be replayed.

**Initial mode:** Report-only.

**Reason for staged deployment:** Token protection can expose application or client compatibility issues. It should be treated as a compatibility-sensitive control.

**Validation:** Review sign-in logs and explicitly test the desktop clients used in the lab before enforcement.

---

### ASTRA-CA-10-BLOCK-DEVICE-CODE-FLOW

**Intent:** Block OAuth device-code authentication unless a documented workload genuinely requires it.

**Target:** Users and cloud applications where device-code flow is not an approved dependency.

**Exception rule:** Any exception must identify the workload, owner, reason and review date.

**Validation:** Check developer tools, CLI workflows and headless-device scenarios before enforcement.

---

### ASTRA-CA-11-BLOCK-AUTH-TRANSFER

**Intent:** Disable authentication-transfer flows that are not required by the Astra environment.

**Initial mode:** Report-only or scoped pilot where available.

**Validation:** Confirm browser/mobile sign-in workflows still operate as expected and record any legitimate dependency before enforcement.

---

### ASTRA-CA-12-EMERGENCY-ACCESS

**Intent:** Preserve tenant recovery if an ordinary Conditional Access policy is misconfigured.

**Astra design:**
- maintain dedicated emergency-access identities;
- exclude them from ordinary Conditional Access policies where necessary to preserve recovery;
- protect credentials and authentication methods separately;
- monitor every sign-in and configuration change involving these accounts;
- test the recovery process periodically.

The emergency-access design must not depend entirely on the same authentication method, device requirement or Conditional Access policy that it exists to recover from.

## BYOD extension

These policies are added only when personal-device access is deliberately in scope.

### ASTRA-CA-BYOD-01-UNMANAGED-WINDOWS-WEB

**Intent:** Keep unmanaged Windows access browser-based and restrict the ability to move organisational data onto the local device.

**Implementation note:** The exact session and download controls depend on the licensed Microsoft services and application being protected. Confirm prerequisites before treating this as enforceable.

**Validation:** Test browser access, download, sync, desktop-client access and sign-out behaviour from a deliberately unmanaged test device.

---

### ASTRA-CA-BYOD-02-MOBILE-MANAGED-APPS

**Intent:** Require supported iOS/Android access to use approved applications with an Intune App Protection Policy.

**Validation:** Test Outlook/Teams or selected Microsoft 365 apps using a personal test device without full device enrolment. Confirm corporate data handling follows the App Protection Policy.

---

### ASTRA-CA-BYOD-03-SHORTER-SESSIONS

**Intent:** Give unmanaged/BYOD sessions a shorter sign-in lifetime than fully managed devices.

**Reasoning:** The device has fewer organisation-controlled security and compliance signals, so the session itself becomes a stronger compensating control.

**Validation:** Confirm the shorter interval is observable and does not create an unusable authentication loop.

## Exclusion register

Every exclusion should be recorded using this structure:

| Field | Example |
| --- | --- |
| Policy | ASTRA-CA-10-BLOCK-DEVICE-CODE-FLOW |
| Excluded object | Test automation identity |
| Reason | CLI workflow under validation |
| Owner | Astra lab administrator |
| Added | YYYY-MM-DD |
| Review date | YYYY-MM-DD |
| Removal criteria | Replace workflow or prove requirement |

## Minimum validation set

Before changing a policy from design/report-only to enforced, capture:

- policy name and revision;
- target and exclusion groups;
- test identity;
- test device and management state;
- expected result;
- observed result;
- relevant sign-in log outcome;
- rollback method;
- unresolved compatibility issue;
- evidence file or journal entry.

See [Rollout and validation](rollout-validation.md) for the full lifecycle.

## Source influence

The policy stack was conceptually inspired by a Microsoft 365 Conditional Access baseline that separates a locked-down managed-device posture from additional BYOD controls. Astra keeps that layered idea but changes the policy catalogue, emergency-access treatment, validation model and scope to fit a personal infrastructure lab.

