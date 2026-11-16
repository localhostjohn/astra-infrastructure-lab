# Windows Server Security, Delegation and Service Accounts

**Status:** Historical lab exercises recorded; permission matrix and fresh retesting pending.

## Principles

- Use standard user identities for routine work and separate privileged identities for administration.
- Delegate the minimum scope needed to a role group; avoid Domain Admins for normal OU operations.
- Prefer role groups to direct user ACLs; record ownership and review memberships.
- Protect service-account credentials, avoid interactive logon where not needed and document credential rotation.
- Do not publish passwords, tokens, private IPs, actual directory DNs, ACL dumps or real accounts.

## Previously recorded activity

The [existing AD documentation](../active-directory.md) records dedicated privileged accounts, role-based security groups, OU delegation, and a service-account exercise with batch-logon rights and a validated scheduled task. This is **historical evidence**; present deployment state and effective access need to be checked again.

## Delegation test matrix

| Persona | Action | Expected | Observed |
| --- | --- | --- | --- |
| Standard lab user | Modify protected OU | Denied | Not captured |
| Delegated test admin | Modify intended test OU object | Allowed | Not captured |
| Delegated test admin | Modify out-of-scope OU | Denied | Not captured |
| Separate privileged admin | Approved elevated task | Allowed under controlled context | Not captured |

Record identity type, lab OU scope, group membership, command or GUI action, timestamp and result. Perform only in an authorised disposable lab.

## Service-account exercise

1. Describe the exact scheduled workload and required local/resource permissions.
2. Use an identity dedicated to that workload.
3. Grant only the required `Log on as a batch job` right and file/network access.
4. Prevent unnecessary privileged group membership and interactive access.
5. Confirm scheduled-task execution **under the intended identity**, not merely that a task exists.
6. Record failure behaviour, credential expiry/rotation and removal procedure.

## Read-only checks

```powershell
Import-Module ActiveDirectory
Get-ADGroupMember -Identity "<LAB_ROLE_GROUP>" |
  Select-Object Name, ObjectClass
Get-ADUser -Identity "<LAB_SERVICE_ACCOUNT>" -Properties Enabled, PasswordLastSet |
  Select-Object Name, Enabled, PasswordLastSet
Get-ScheduledTask | Select-Object TaskName, TaskPath, State
```

These commands require suitable privileges and tools. Avoid collecting or publishing sensitive details. Membership and task listings are **inputs to** a security review, not proof of least privilege.

## Evidence outstanding

- [ ] Approved role and permission matrix.
- [ ] One successful permitted delegation test.
- [ ] One unsuccessful out-of-scope test.
- [ ] Scheduled-task identity and success/failure observations.
- [ ] Recovery/revocation test and dated result.
