# Backup and Restore Evidence Template

> Copy this template into a dated evidence file before recording an exercise. Leave the status as NOT RUN until the activity has actually been performed and reviewed.

## Exercise metadata

| Field | Value |
| --- | --- |
| Date | |
| Operator | |
| Exercise ID | |
| Exercise type | Disposable drill / Repository integrity / Isolated application recovery |
| Host | Sanitised description only |
| Backup technology | Restic |
| Repository | Sanitised description only |
| Snapshot | Sanitised identifier or description |
| Start time | |
| End time | |
| Measured recovery time | |

## Objective

Describe exactly what is being tested and what constitutes success.

## Recovery targets

| Metric | Target | Measured |
| --- | --- | --- |
| RPO | Not defined | Not measured |
| RTO | Not defined | Not measured |

## Preconditions

- [ ] Restore scope has been identified.
- [ ] Source/test data is non-sensitive or suitably sanitised.
- [ ] Restore destination is isolated from live application data.
- [ ] Required credentials are available privately.
- [ ] Sufficient disk space has been confirmed.
- [ ] Dependencies and rollback/recovery path have been reviewed.

## Validation record

| Check | Expected result | Actual result | Status |
| --- | --- | --- | --- |
| Snapshot/repository access | Intended recovery source can be identified | | Not run |
| Repository integrity | No blocking integrity error | | Not run |
| Restore | Completes without unexpected error | | Not run |
| File scope | Expected files/directories are present | | Not run |
| Checksums/content | Restored data matches reference data | | Not run |
| Permissions | Ownership/mode are appropriate | | Not run |
| Application start | Selected application starts, if applicable | | Not run |
| Application behaviour | Defined functional check succeeds | | Not run |
| Monitoring | Recovered service becomes healthy, if applicable | | Not run |

## Sanitised commands

Do not include passwords, tokens, private repository URLs, employer values or sensitive file paths.

```text
Not recorded
```

## Result

**Status:** NOT RUN

## Problems encountered

Record failures and unexpected behaviour rather than removing them from the final write-up.

## Corrective actions

Record any changes required to complete or improve the recovery procedure.

## Limitations

State what this exercise does **not** prove.

## Lessons learned

Explain what the exercise demonstrated about backup design, dependencies, validation and operational readiness.

## Publication review

- [ ] No credentials, keys or tokens.
- [ ] No private repository endpoint.
- [ ] No employer information.
- [ ] No personal or customer data.
- [ ] Hostnames, addresses and paths sanitised where needed.
- [ ] Passed claims link to actual dated evidence.
