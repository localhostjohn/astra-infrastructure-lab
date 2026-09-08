# Windows Server and Active Directory Lab

## Learning objectives

Build confidence with AD DS, DNS, OU design, Group Policy, delegated administration, security groups and service accounts. The lab is designed to demonstrate the reasoning behind configuration decisions and the ability to validate and troubleshoot them.

## Work completed in earlier lab exercises

- Deployed a Windows Server instance in a personal Azure environment for directory-administration practice.
- Established an OU structure that separates normal staff accounts from built-in/default objects.
- Created role-based security groups and exercised delegated administration with dedicated privileged accounts.
- Configured multiple GPOs, including removable-storage restriction/exception and shared-drive policy exercises.
- Created a dedicated service account and security group, configured the required batch-logon right and validated an actual scheduled task.

These statements reflect recorded exercises; they do not establish that every configuration remains deployed today. No real domain names, usernames, passwords, OU distinguished names or screenshots are included.

## Reference OU and permission model

```text
ad.astra.example.test
├── Staff
│   ├── Users
│   ├── Computers
│   └── Groups
├── Admin Accounts
├── Service Accounts
└── Servers
```

This is a simplified illustrative model, not an export of the deployed directory. The default `Users` container and built-in objects should be treated separately from custom OUs. A real design must account for inheritance, delegated permissions, Group Policy scope and the organisation's operational requirements.

## Delegated administration exercise

1. Define a role and the exact directory tasks it requires.
2. Create a security group for that role and use a dedicated test administrator.
3. Delegate only the required permissions on a lab OU.
4. Test permitted actions with the delegated identity.
5. Test an action that should be denied, and record the result.
6. Review group memberships and inherited permissions before considering the exercise complete.

Do not use Domain Admins as a shortcut for routine OU administration. Avoid embedding administrator credentials in scripts or publishing actual security descriptors from a real environment.

## GPO exercise

For the removable-storage restriction/exception scenario, document the intended users/computers, policy scope, security filtering, precedence and rollback. Use a disposable test client and validate the effective policy with tools such as `gpresult` and Event Viewer. Record both the restricted and exception test results, including the account context and expected behaviour, using fictional identities in public evidence.

An Entra group does not automatically become an AD security group or grant on-premises GPO filtering rights. Any hybrid group or identity relationship must be explicitly designed and validated rather than assumed.

## Service account exercise

A scheduled-task identity should have only the permissions and logon rights required for its specific workload. The previous lab exercise validated batch-logon configuration and scheduled-task execution. A stronger follow-up is to document the task's purpose, effective identity, file/resource permissions, failure behaviour and credential-rotation approach. Avoid interactive use and broad administrative membership unless there is a demonstrated requirement.

## Validation evidence to add

| Evidence | What it should demonstrate | Status |
| --- | --- | --- |
| Sanitised OU diagram | Logical structure and object separation | To be recreated |
| Delegation test | Allowed and denied administrative actions | To be documented |
| GPO result | Effective policy and exception behaviour | To be documented |
| Scheduled-task log | Successful execution under the intended identity | To be documented |
| DNS health check | Directory-related DNS resolution | To be captured in a new lab session |

No screenshots or output are attached until they have been reviewed for internal identifiers and secrets.

## Next steps

Develop repeatable PowerShell checks, document GPO backup and restore, test delegated permissions against a written access matrix, and plan a separate hybrid identity exercise. Do not introduce Entra synchronisation until the directory namespace, UPN design, test identities, licensing and rollback approach have been reviewed.

## References

- [AD DS overview](https://learn.microsoft.com/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)
- [Group Policy overview](https://learn.microsoft.com/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview)
- [PowerShell ActiveDirectory module](https://learn.microsoft.com/powershell/module/activedirectory/)
- [Microsoft Entra Connect documentation](https://learn.microsoft.com/entra/identity/hybrid/connect/)

## Read-only automation example

The [AD inventory script](../scripts/README.md) is a first step toward repeatable diagnostics. It uses read-only ActiveDirectory cmdlets and optional, explicit local report export. Its mock tests and live-lab results remain to be validated; do not represent the example as a completed health check.
