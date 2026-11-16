# Active Directory Domain Services and DNS

**Status:** Historical configuration exercises recorded; fresh validation outstanding.

## Recorded work

Existing Astra notes describe a Windows Server VM in a personal Azure environment, an OU design separating ordinary users from administrative and service identities, role-based security groups, delegated administration, removable-storage and shared-drive GPO exercises, and a dedicated service account used by a scheduled task.

The owner also reports a VirtualBox AD DS lab. Its actual domain configuration, DNS settings and relationship to the Azure environment must be established rather than assumed.

The [existing AD overview](../active-directory.md) remains the authoritative record of those historical exercises.

## Reference directory design (fictional)

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

This is a proposed/sanitised logical structure, **not** a live AD export. Default built-in containers and inheritance require separate consideration.

## Why DNS matters

- AD DS relies on DNS SRV records for domain-controller location and related services.
- Domain clients must query resolvers that can locate their AD domain records.
- Directory functionality depends on sound IP addressing, time synchronisation, appropriate firewall rules and usable domain-controller health.
- An Azure-hosted domain controller introduces availability and network dependencies for any remote clients; no such cross-network access is currently claimed as verified.

## Read-only PowerShell validation

On an authorised domain controller or admin workstation with RSAT:

```powershell
Import-Module ActiveDirectory
Get-ADDomain | Select-Object DNSRoot, DomainMode, PDCEmulator
Get-ADForest | Select-Object RootDomain, ForestMode
Get-ADDomainController -Filter * |
  Select-Object HostName, Site, IPv4Address, IsGlobalCatalog
Get-DnsServerZone -ErrorAction SilentlyContinue |
  Select-Object ZoneName, ZoneType, IsDsIntegrated
Resolve-DnsName -Type SRV "_ldap._tcp.dc._msdcs.<LAB_DOMAIN>"
dcdiag /test:dns
```

`Get-DnsServerZone` requires the DNS Server module/permissions; `dcdiag` requires the relevant admin tools. A single successful SRV lookup is not proof of full directory health. Do not publish actual DNS names or controller IPs.

## Live evidence matrix

| Test | Expected behaviour | Actual result |
| --- | --- | --- |
| AD domain discovery | Authorised query returns expected lab domain | Not captured |
| Controller discovery | Expected DCs returned | Not captured |
| DNS SRV lookup | Expected AD locator records resolve | Not captured |
| AD service state | Expected services healthy | Not captured |
| Client domain join | Disposable client joins intended lab domain | Not captured |
| Authentication | Standard lab user can sign in | Not captured |
| Time resolution | Client and DC show suitable time source | Not captured |
| Replication | Tested only if >1 DC exists | Not applicable until topology confirmed |

## Automation

The repository's [read-only inventory script](../../scripts/Get-AstraADHealth.ps1) and [mock-test evidence](../../evidence/2026-09-08-ad-inventory-unit-tests.md) are useful artefacts. **Six mocked unit tests do not establish live AD health**. Carry out and document a separately dated authorised lab run.

## Next actions

- [ ] Verify whether VirtualBox and Azure are standalone labs or connected.
- [ ] Capture an anonymised logical OU and DNS architecture.
- [ ] Record actual domain and DNS health results without live identifiers.
- [ ] Document one representative fault, diagnostic process and resolution.
