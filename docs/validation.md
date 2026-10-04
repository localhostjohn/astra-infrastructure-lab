# Validation and Evidence Register

A portfolio should distinguish a successful build from a validated service. This register records what is known from earlier exercises and what still needs evidence. It is deliberately not a fabricated test report.

## Evidence standard

For each exercise, record the objective, lab-only prerequisites, expected result, actual result, date, tool/version, evidence reference and any corrective action. A result is **Passed** only after the actual test has been performed. Use **Recorded previously** for exercises whose original evidence has not yet been reviewed for publication, and **Not yet validated** for planned tests.

| ID | Workstream | Expected result | Current status | Evidence to add |
| --- | --- | --- | --- | --- |
| AD-01 | Directory | Lab identities and computers can be administered through the intended role | Recorded previously | Sanitised directory/role diagram |
| AD-03 | Automation | Read-only inventory runs and Pester tests pass against fictional fixtures | Not yet validated | Actual Pester output and sanitised lab result |
| AD-02 | Delegation | Allowed task succeeds and out-of-scope task is denied | Recorded previously | Recreated permissions test |
| GPO-01 | Policy | Restriction and exception apply to intended targets | Recorded previously | Sanitised `gpresult` and test notes |
| SVC-01 | Service account | Scheduled task runs under intended identity | Recorded previously, execution validated | Redacted task result and effective permissions |
| AZ-01 | Cloud | Lab VM/network can be managed through authorised access | Recorded previously | Sanitised topology and connectivity tests |
| PI-01 | Linux | Pi and Docker operate correctly | Recorded previously | Version/health output |
| NET-02 | Private remote access | Authorised endpoint reaches private service through Tailscale subnet routing and Split DNS over cellular | **Passed — 26 September 2026** | Sanitised end-to-end validation record |
| PI-02 | Remote access | Private SSH connection succeeds | Recorded previously, access validated | Recreated access test |
| MON-01 | Monitoring | Service status and alert behave as defined | Not yet fully validated | Alert test and recovery result |
| DNS-01 | DNS | Filtering and allowlist changes behave as expected | Not yet fully validated | Query-log test using fictional domains |
| DNS-02 | Private DNS | Tailscale Split DNS resolves the private service namespace through AdGuard Home | **Passed — 26 September 2026 for the tested namespace and endpoint** | Sanitised DNS resolution and remote-access record |
| TLS-01 | Private TLS | Private service certificate chains to the Astra Root CA and is trusted by the test client | **Passed — 26 September 2026** | Sanitised certificate inspection and browser validation |
| PKI-01 | Internal PKI | Root CA → issuing CA → client certificate chain validates as designed | **Passed — 3 October 2026** | Sanitised chain inspection and client-certificate properties |
| PKI-02 | Device trust / mTLS | Trusted client certificate is accepted and a client without a certificate is rejected before backend access | **Passed — 3 October 2026 for the tested Windows endpoint and proxy path** | Sanitised positive browser test and negative HTTP 400 result |
| PKI-03 | Multi-platform device trust | A second administrator platform uses a unique Astra client certificate and passes the same positive/negative mTLS pattern | **Passed — 4 October 2026 for the tested macOS endpoint** | Sanitised certificate-selection and HTTP 400 test results |
| SEC-01 | Protected administration path | Portainer requires an Astra-issued client certificate through Nginx Proxy Manager while direct recovery access remains available | **Passed — 4 October 2026** | Sanitised client-certificate prompt, negative HTTP 400 result and recovery-path check |
| BAK-01 | Backup | Snapshot is created and verified | Recorded previously | Sanitised snapshot metadata |
| BAK-02 | Recovery | Restored test data matches expected data | Not yet validated | Restore log and checksum comparison |
| HYB-01 | Hybrid identity | Scoped identities synchronise as designed | Planned | Design and end-to-end test |
| NET-01 | Segmentation | Intended traffic allowed; prohibited traffic denied | Planned | VLAN/routing/ACL test matrix |

## Evidence handling

Use recreated diagrams, fictional identities and redacted outputs. Remove credentials, tokens, public IP addresses that identify the home environment, internal DNS names, tenant IDs, subscription IDs, device serial numbers and employer information before publication. Check image metadata and terminal scrollback as well as visible content.

A private original may be retained only in an appropriately authorised location. Public evidence should explain the result without exposing the real environment. Do not edit screenshots in a way that falsely changes the outcome of a test; recreate the exercise or clearly label an illustrative example instead.

## Test record template

```text
ID:
Objective:
Environment (sanitised):
Prerequisites:
Expected result:
Actual result:
Date:
Tool / version:
Evidence reference:
Status: Not run | Passed | Failed | Blocked
Troubleshooting / corrective action:
Retest result:
Lessons learned:
```
