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
| PI-02 | Remote access | Private SSH connection succeeds | Recorded previously, access validated | Recreated access test |
| MON-01 | Monitoring | Service status and alert behave as defined | Not yet fully validated | Alert test and recovery result |
| DNS-01 | DNS | Filtering and allowlist changes behave as expected | Not yet fully validated | Query-log test using fictional domains |
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
