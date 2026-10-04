# Astra Network Triage validation — 2 October 2026

Windows PowerShell 5.1 CI passed on Windows Server 2025 using Pester 5.9.1.

- Tested source commit: `f4627a87a593acc1019d21a7a2f223c30508fafc`
- [Successful workflow run](https://github.com/localhostjohn/astra-infrastructure-lab/actions/runs/36985297475)
- Result: **18 passed, 0 failed, 0 skipped**.
- Network triage: 12 tests passed (nine mocked interpretation/export cases; actual Windows network inventory; actual loopback TCP open/refused connection; IPv6 literal resolution).
- Existing AD inventory regression suite: six mocked tests passed.

The initial loopback test caught an internal .NET task result leaking into the TCP diagnostic output. Assigning that result to `$null` corrected the output contract. Null gateway/address filtering was added for partially configured interfaces and validated against the Windows runner.

These results establish the tested code behaviours on the runner. They do not establish connectivity to Astra services. Live HTTP/TLS probes, Windows desktop execution, PowerShell 7 execution and the [controlled lab scenarios](../tools/network-triage/LAB-SCENARIOS.md) remain to be validated. HTTP failure interpretation is mocked; live HTTP transport is not covered by this run. The sample report is fictional.
