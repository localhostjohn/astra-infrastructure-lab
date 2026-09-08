# Read-only Active Directory Inventory

This PowerShell example collects directory metadata for troubleshooting and learning without modifying AD objects, permissions, policies or services. It is intended for an owned or explicitly authorised lab.

## Status and scope

The source has been reviewed for read-only operation, but the Pester tests and real-directory execution have **not been run in this preparation environment**. The included tests use fictional objects and must be executed before reporting a passing result. This is not a production monitoring agent, a complete AD health assessment or a substitute for `dcdiag`, `repadmin` or appropriate operational monitoring.

The script queries domain and forest metadata and lists domain controllers. Optional replication checks retrieve currently recorded failures for the discovered domain. A completed query means the query succeeded; it does not prove that replication, DNS, time, SYSVOL, security or every domain controller is healthy. The script does not force replication, perform repairs, change group memberships or export user accounts.

## Prerequisites

Use Windows PowerShell 5.1 on a Windows workstation or server with the Microsoft ActiveDirectory module available through the appropriate RSAT/server feature. Run in your own lab using an account with sufficient directory read permissions. Network connectivity, DNS resolution and the required AD Web Services access must be available. Do not change execution policy, install RSAT or elevate privileges without understanding your environment's requirements.

```powershell
$PSVersionTable.PSVersion
Get-Module -ListAvailable ActiveDirectory
Get-Command Get-ADDomain, Get-ADForest, Get-ADDomainController, Get-ADReplicationFailure
```

## Run the inventory

From the repository root, review the source and run:

```powershell
.\scripts\Get-AstraADHealth.ps1
```

To use a particular lab domain controller and include replication-failure information:

```powershell
.\scripts\Get-AstraADHealth.ps1 -Server dc01.lab.example.test -IncludeReplication
```

To save a local JSON report, create a private directory outside the repository and specify a new filename:

```powershell
New-Item -ItemType Directory -Path "$HOME\AstraPrivate" -Force
.\scripts\Get-AstraADHealth.ps1 -OutputPath "$HOME\AstraPrivate\ad-health.json"
```

No file is written unless `-OutputPath` is supplied. Existing reports are not overwritten. The generated JSON can contain real hostnames, domain names, sites and other private metadata; do not commit it or publish it unredacted. Store sensitive reports outside the repository where possible.

## Test the code

On a test machine with Pester 5 installed through an approved method:

```powershell
Import-Module Pester -MinimumVersion 5.0
Invoke-Pester -Path .\tests\Get-AstraADHealth.Tests.ps1 -Output Detailed
```

The tests mock directory queries. They cover the returned inventory structure, explicit server selection, replication-failure reporting, error handling, local JSON output and a static check for directory-mutation commands. They do not prove that a real domain is healthy. Record actual results in the validation register after running them.

## Example report shape

The following is illustrative schema data, not output from a live environment:

```json
{
  "SchemaVersion": "1.0",
  "GeneratedAtUtc": "2026-01-01T12:00:00.0000000Z",
  "OverallStatus": "Completed",
  "Disclaimer": "Read-only inventory; not a complete AD health or security assessment.",
  "Checks": [
    {
      "Name": "Domain",
      "Status": "Completed",
      "Data": { "DNSRoot": "lab.example.test" },
      "Error": null
    }
  ]
}
```

The real report includes additional fields and sections. `Completed` means retrieval succeeded, `Attention` indicates a recorded problem or failed query, and `Skipped` means the check was not attempted. Do not treat an empty failure list as proof that all replication is healthy.

## Next improvements

After validating this baseline, add bounded DNS/SRV checks, an explicit `dcdiag`/`repadmin` evidence runbook, Pester coverage against a disposable test domain, and an optional sanitised summary exporter. Keep diagnostic and remediation tools separate, require review for any changes and never publish raw directory results.

## References

- [ActiveDirectory PowerShell module](https://learn.microsoft.com/powershell/module/activedirectory/)
- [Get-ADDomain](https://learn.microsoft.com/powershell/module/activedirectory/get-addomain)
- [Get-ADForest](https://learn.microsoft.com/powershell/module/activedirectory/get-adforest)
- [Get-ADDomainController](https://learn.microsoft.com/powershell/module/activedirectory/get-addomaincontroller)
- [Get-ADReplicationFailure](https://learn.microsoft.com/powershell/module/activedirectory/get-adreplicationfailure)
- [Pester documentation](https://pester.dev/docs/quick-start)
