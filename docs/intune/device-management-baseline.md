# Astra Intune Device Management Baseline

This document defines the proposed **endpoint-management baseline** for Astra-managed devices. It complements the Conditional Access stack by making "managed" and "compliant" meaningful rather than treating enrolment alone as a security boundary.

The first target platform is Windows. Mobile and BYOD controls are added as separate layers where required.

## 1. Enrolment and device ownership

### ASTRA-ENR-01-WINDOWS-ENROLMENT-RESTRICTIONS

**Intent:** Limit enrolment to supported device types and prevent accidental expansion of the management boundary.

**Design points:**
- define which Windows ownership types are allowed;
- restrict unsupported platforms where appropriate;
- use pilot users before opening enrolment more broadly;
- document any device-limit value and the reason for it.

**Validation:** Enrol one approved test device and attempt one deliberately unsupported enrolment.

---

### ASTRA-ENR-02-DEVICE-NAMING-AND-CATEGORIES

**Intent:** Make managed endpoints easy to identify in Intune, Entra ID, logs and evidence.

**Design:** Use a predictable lab naming standard and optional categories without embedding personal or sensitive data in device names.

**Validation:** Confirm the device can be correlated across Intune, Entra ID and sign-in records.

---

## 2. Compliance

### ASTRA-COMP-01-WINDOWS-COMPLIANCE

**Intent:** Define the minimum security state a Windows device must meet before Conditional Access treats it as trusted.

**Candidate checks:**
- supported operating-system version;
- BitLocker enabled;
- Secure Boot enabled where supported;
- code-integrity requirement where appropriate;
- firewall/antimalware health where the platform exposes a reliable compliance signal;
- no simple password configuration where applicable.

Not every available check should be enabled automatically. Each setting must be confirmed against the actual device type and lab scenario.

**Validation:** Record both a compliant device and a deliberately non-compliant test condition, then verify the compliance status and Conditional Access result.

---

### ASTRA-COMP-02-COMPLIANCE-GRACE-PERIOD

**Intent:** Define how quickly a device moves from a detected compliance problem to blocked access.

**Design:** Use a deliberate grace period for remediable user-facing issues and a faster response for critical conditions where the platform supports it.

**Validation:** Trigger a safe test failure and record detection time, notification behaviour, remediation and return to compliance.

---

## 3. Endpoint security

### ASTRA-SEC-01-WINDOWS-SECURITY-BASELINE

**Intent:** Apply a reviewed Microsoft security baseline as a starting configuration, then document every Astra deviation.

**Rule:** Never assign a vendor baseline globally without first reviewing conflicts with existing configuration profiles and endpoint-security policies.

**Validation:** Export or record the effective setting set, check for conflicts and test normal sign-in, productivity and administration workflows.

---

### ASTRA-SEC-02-DEFENDER-ANTIVIRUS

**Intent:** Keep Microsoft Defender Antivirus active and configured with cloud-delivered protection and appropriate scanning behaviour.

**Design points:**
- real-time protection;
- cloud protection where available;
- scheduled/quick scanning strategy;
- controlled exclusions only when a validated workload requires them;
- tamper-resistant administration where licensing/platform support permits.

**Validation:** Confirm Defender health and use a harmless industry-standard test method rather than real malware.

---

### ASTRA-SEC-03-WINDOWS-FIREWALL

**Intent:** Keep Windows Defender Firewall enabled across applicable network profiles.

**Design:** Add only the inbound/outbound exceptions needed for documented lab services.

**Validation:** Verify expected management/service traffic and one explicit deny case.

---

### ASTRA-SEC-04-BITLOCKER

**Intent:** Encrypt supported Windows system drives and protect recovery material.

**Design points:**
- require encryption on managed devices where supported;
- standardise encryption and startup behaviour;
- escrow recovery information to the approved directory service when the lab supports it;
- never publish recovery keys in screenshots or evidence.

**Validation:** Confirm encryption state, recovery-key presence in the intended management plane and a documented recovery test using a disposable device or VM where practical.

---

### ASTRA-SEC-05-ATTACK-SURFACE-REDUCTION

**Intent:** Reduce common executable, script and credential-abuse paths.

**Deployment approach:** Start higher-impact ASR rules in audit mode, review events, then move selected rules through pilot to block mode.

**Validation:** Record rule state, audit events, application compatibility and any exception with its reason.

---

### ASTRA-SEC-06-ACCOUNT-PROTECTION

**Intent:** Reduce standing local-administrator access and protect local recovery administration.

**Design points:**
- use Windows LAPS for local administrator password rotation where supported;
- keep normal users out of local Administrators unless a documented lab requirement exists;
- manage local group membership through a controlled policy rather than manual drift.

**Validation:** Confirm local-admin membership, password rotation/retrieval workflow and successful recovery without exposing the credential in public evidence.

---

### ASTRA-SEC-07-WINDOWS-HELLO

**Intent:** Provide a strong device-bound sign-in method for managed Windows users.

**Design:** Configure Windows Hello for Business only after confirming the identity/join model and recovery experience.

**Validation:** Test provisioning, normal sign-in and recovery/re-registration.

---

## 4. Configuration baseline

### ASTRA-CFG-01-EDGE-ENTERPRISE-SETTINGS

**Intent:** Define a small set of browser controls that support secure sign-in and predictable management without turning the lab into a policy dump.

**Candidate areas:** update behaviour, password-manager decision, download/security prompts and sign-in/profile handling.

**Validation:** Verify settings in the browser policy page and confirm expected browsing behaviour.

---

### ASTRA-CFG-02-ONEDRIVE-KNOWN-FOLDER-MOVE

**Intent:** Demonstrate managed user-data redirection and recovery patterns on a test endpoint.

**Status:** Optional lab exercise, not a prerequisite for the security baseline.

**Validation:** Confirm Desktop/Documents redirection, sync state and rollback using non-sensitive test files.

---

## 5. Windows servicing

### ASTRA-UPD-01-WINDOWS-UPDATE-PILOT

**Intent:** Create a small update ring that receives quality updates before the broader managed-device group.

**Design:** Keep restart/deadline behaviour explicit and document the pilot population.

**Validation:** Record update detection, installation, restart experience and resulting build.

---

### ASTRA-UPD-02-WINDOWS-UPDATE-BROAD

**Intent:** Apply the validated update strategy to the main Astra managed-device group after the pilot has completed.

**Rule:** Do not use the same deployment ring as both pilot and broad production-style scope.

---

### ASTRA-UPD-03-FEATURE-UPDATE-CONTROL

**Intent:** Keep managed Windows devices on a deliberate supported feature release rather than allowing uncontrolled version drift.

**Validation:** Record intended target version and observed device version.

---

## 6. Application management

### ASTRA-APP-01-CORE-APPLICATIONS

**Intent:** Make a small, documented set of required applications available through Intune.

**Examples for the lab:** Company Portal and selected administration/productivity tools that have a genuine lab purpose.

**Rule:** Avoid publishing commercial software packages, internal employer applications or licence material.

**Validation:** Test install, detection, update/reinstall behaviour and uninstall where applicable.

---

### ASTRA-APP-02-APPLICATION-INVENTORY

**Intent:** Use Intune inventory data to understand the managed software estate and identify drift.

**Validation:** Compare expected core software with observed inventory on a test device.

---

## 7. BYOD and mobile application management

### ASTRA-MAM-01-BYOD-APP-PROTECTION

**Intent:** Protect organisational data in approved mobile apps without requiring full device enrolment.

**Candidate controls:**
- require an app PIN or approved authentication behaviour;
- restrict transfer of organisational data to unmanaged apps;
- control save-as/copy-paste behaviour according to the lab scenario;
- support selective wipe of organisational app data.

**Validation:** Use a personal test device or simulator with non-sensitive lab data and verify allowed/blocked data paths.

---

### ASTRA-MAM-02-MOBILE-CA-INTEGRATION

**Intent:** Pair the App Protection Policy with Conditional Access so that users cannot bypass the managed-app requirement through an unprotected access route.

See [Conditional Access baseline](conditional-access-baseline.md).

## 8. Device lifecycle

### ASTRA-DEV-01-INACTIVE-DEVICE-REVIEW

**Intent:** Periodically review stale managed-device records instead of allowing the inventory to grow indefinitely.

**Design:** Define inactivity criteria and a manual review/retirement process before introducing automated cleanup.

---

### ASTRA-DEV-02-RETIRE-WIPE-RECOVERY

**Intent:** Document the difference between retire, wipe, delete and selective app-data removal before using any destructive device action.

**Validation:** Perform destructive testing only on a disposable VM/test device with a known recovery route.

## Assignment model

Use groups that describe **role in the rollout**, not a specific person:

```text
ASTRA-GRP-INTUNE-PILOT
ASTRA-GRP-INTUNE-MANAGED-WINDOWS
ASTRA-GRP-INTUNE-BYOD-MOBILE
ASTRA-GRP-INTUNE-ADMINS
ASTRA-GRP-INTUNE-EXCEPTIONS-<PURPOSE>
```

Assignments should be traceable from policy → group → test evidence.

## Conflict rule

Where the same Windows setting can be configured through multiple Intune policy types, choose one authoritative source for that setting wherever practical. Security baselines, Settings Catalog, Endpoint Security and legacy templates should not be layered blindly.

Record any unavoidable overlap and prove the effective result on the endpoint.

