# AD Inventory Unit-Test Evidence

**Date recorded:** 8 September 2026  
**Project:** Astra Infrastructure Lab  
**Script:** `scripts/Get-AstraADHealth.ps1`  
**Test suite:** `tests/Get-AstraADHealth.Tests.ps1`  
**Evidence source:** Results supplied by the project maintainer from a local Windows PowerShell session. This record is a sanitised transcription, not an independently observed test run or a GitHub Actions result.

## Objective

Validate the script's expected behaviour using mocked Active Directory responses before running any queries against the live Astra lab. The tests must not modify directory objects or require access to a domain controller.

## Environment and execution

The repository was cloned from GitHub onto a Windows workstation. The machine initially had Pester 3.4.0; Pester 5.9.1 was subsequently installed and used for the test run. The test command was:

```powershell
Invoke-Pester -Path .\tests\Get-AstraADHealth.Tests.ps1 -Output Detailed
```

The exact Windows build and PowerShell patch version were not captured. No live domain name, host identifier, account name or private path is included in this record.

## Reported result

| Metric | Result |
| --- | --- |
| Pester version | 5.9.1 |
| Tests discovered | 6 |
| Passed | 6 |
| Failed | 0 |
| Skipped | 0 |
| Inconclusive | 0 |
| Not run | 0 |
| Reported duration | 1.54 seconds |

The maintainer reported that all six tests completed successfully. The passing cases covered inventory structure, explicit server selection, replication-failure reporting, individual query-error handling, opt-in JSON output with overwrite protection, and a static check for directory-mutation or arbitrary-command execution calls.

## Interpretation and limitations

This is evidence that the six mocked unit tests passed in the reported local session. It is not proof that the script is free of defects, that every possible mutation is excluded, or that a real Active Directory environment is healthy. No live domain, forest, domain-controller or replication result has been supplied for this evidence entry.

The GitHub Actions workflow is a separate validation mechanism. Its result must be recorded independently after a completed run is available. No CI pass is claimed here.

## Next validation

1. Confirm the ActiveDirectory module is available on an authorised Astra lab workstation or server.
2. Run the script without `-OutputPath` and review the returned inventory privately.
3. If the initial queries succeed, run the optional replication-failure check.
4. Record the actual outcome, including any failures or limitations, in a separate sanitised evidence entry.
5. Do not publish raw AD reports, real hostnames, private addresses, credentials or employer information.

**Status:** Local mocked unit tests passed, as reported by the maintainer. Live-lab validation remains outstanding.
