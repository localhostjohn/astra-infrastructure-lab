# Astra Network Triage — v0.1.0

A Windows PowerShell tool for answering: **this device cannot reach a service; which layer needs investigation?** It collects evidence for one named host and port and suggests next checks. It makes no network configuration changes.

## Run

Requires Windows 10/11 or Windows Server, Windows PowerShell 5.1 or PowerShell 7, and the built-in NetTCPIP module for local inventory. Administrator rights are not normally required. No third-party runtime modules are required.

From the repository root:

```powershell
# Test a web endpoint: direct unauthenticated GET /, with certificate validation.
$report = .\tools\network-triage\Invoke-AstraNetworkTriage.ps1 `
    -Target portal.example.test -Port 443 -HttpScheme https
$report.Checks | Format-Table Name, Status, Detail -Wrap
$report.Checks | Where-Object Status -in Attention, Error | Select-Object Name, NextStep

# Test another service without sending HTTP traffic.
.\tools\network-triage\Invoke-AstraNetworkTriage.ps1 -Target server.example.test -Port 3389

# Optional local JSON and text reports; use a private location outside Git.
.\tools\network-triage\Invoke-AstraNetworkTriage.ps1 `
    -Target portal.example.test -Port 443 -HttpScheme https `
    -TimeoutSeconds 3 -OutputDirectory "$HOME\AstraPrivate\NetworkTriage"
```

Replace fictional targets with your own lab targets. Supply a hostname or bare IPv4/IPv6 address, not a URL. HTTP scheme does not select the port: use `-Port 80 -HttpScheme http` for an HTTP service on port 80. The script returns an object; no report is written unless an output directory is provided. Reports get unique names and are opened with CreateNew to prevent overwriting. A diagnostic Attention result is report data, not a terminating PowerShell error or a process exit-code contract.

## Checks and interpretation

| Check | Evidence | Limits |
| --- | --- | --- |
| LocalNetwork | Interface indices, addresses, gateways, DNS servers, default routes | Inventory only; not an assertion of selected route, adapter state or valid DHCP |
| Resolution | OS resolver returns addresses; IP literals bypass resolution | Includes hosts file/cache and OS policy; does not separately test each DNS server |
| ICMP | Ping status per tested address | Filtering can cause failure while TCP remains reachable |
| TCP | Connection result per address to the requested port | Does not distinguish firewall, routing and listener failures with certainty |
| HTTP | Optional GET / status or error; TLS validation retained | Direct connection, no system proxy or credentials, redirects not followed; body not downloaded |

`Pass` means that particular check succeeded. `Observed` means configuration was collected. `Attention` means investigation is needed. `Inconclusive` means ICMP did not establish reachability. `Error` means an evidence collector failed. `Skipped` means a check was not attempted. Overall `Completed` means no Attention/Error was recorded; it is not a declaration that the network is healthy.

A 401/403 or redirect can be expected for an operational service. These responses are flagged for interpretation while preserving that an HTTP response was received. An HTTPS error after successful TCP can involve TLS, trust, naming or application behaviour. Windows PowerShell 5.1 uses the host's .NET/TLS defaults; the tool does not change them or disable certificate validation.

At most eight resolved addresses are probed. Timeouts apply per operation, not to the whole run; two operations per address can take up to 16 times the configured timeout, plus resolution, inventory and optional HTTP. Local inventory uses Windows cmdlets without a custom timeout. Timed-out OS DNS work may finish in the background. HTTP resolves the hostname again to preserve Host/SNI; its selected address may differ from the individual TCP probes. No public connectivity endpoint, subnet scan, traceroute, packet capture, repair or remote upload is performed.

## Validation

```powershell
Import-Module Pester -MinimumVersion 5.0
Invoke-Pester .\tests\AstraNetworkTriage.Tests.ps1 -Output Detailed
```

Tests cover filtered ICMP with successful TCP, failed DNS dependency handling, TCP failure, HTTP 403, TLS error, local collector failure, address caps, target validation, report export, actual loopback TCP success/refusal and IPv6 literals. Existing GitHub Windows CI runs this suite alongside the AD inventory suite.

The authoring environment has no PowerShell runtime. Runtime results must be taken from CI and the manual lab exercise, not inferred from source review. See [LAB-SCENARIOS.md](LAB-SCENARIOS.md) for controlled experiments and an evidence template. [sample-report.txt](sample-report.txt) is fictional illustrative output, not a lab result.

## Portfolio design

Kept in Astra as a focused reusable tool, with a module separating probes from interpretation and export. It can later be extracted into a standalone repository or called by Astra Windows Toolbox. First collect genuine lab evidence before adding a GUI or remediation features.

Raw reports contain hostnames, addresses, routes, DNS servers and exception details. Keep them private and recreate or sanitise examples before publishing. The included `.gitignore` protects the conventional reports directory, not every possible export location.
