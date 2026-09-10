# Backup and Restore Evidence Template

> Copy this file before recording an exercise. Do not mark an item as passed unless the corresponding activity was actually completed and reviewed.

## Exercise metadata

| Field | Value |
| --- | --- |
| Date | |
| Operator | |
| Exercise type | Disposable drill / Live-lab isolated restore |
| Host | Sanitised value only |
| Backup technology | Restic |
| Repository | Sanitised description only |
| Snapshot | Sanitised ID or description |
| Start time | |
| End time | |
| Measured recovery time | |

## Objective

Describe what is being recovered and what successful recovery means.

## Preconditions

- [ ] Source data is non-sensitive or suitably sanitised.
- [ ] Restore destination is isolated from live application data.
- [ ] Required backup credentials are available privately.
- [ ] Sufficient disk space has been confirmed.
- [ ] Recovery procedure and rollback path have been reviewed.

## Validation record

| Check | Expected result | Actual result | Status |
| --- | --- | --- | --- |
| Backup/snapshot exists | Intended snapshot can be identified | | Not run |
| Repository check | No blocking integrity error | | Not run |
| Restore command | Completes without unexpected error | | Not run |
| File count | Restored files match expected scope | | Not run |
| Checksums | Restored hashes match source/reference hashes | | Not run |
| Permissions | Ownership/mode appropriate for restored data | | Not run |
| Application check | Application-specific validation succeeds, if applicable | | Not run |

## Commands used

Record sanitised commands only. Remove repository URLs, tokens, private addresses, passwords and real internal names.

```text
Not recorded
```

## Evidence summary

Describe the evidence retained privately and any sanitised evidence published in this repository.

## Result

**Status:** NOT RUN

Do not change this to PASS until all required success criteria have been met.

## Recovery objectives

**Observed RPO:** Not measured

**Observed RTO:** Not measured

## Problems encountered

Record failures, missing dependencies, unexpected permissions or restore issues.

## Corrective actions

Record what was changed following the exercise.

## Lessons learned

Explain what the exercise demonstrated about backup design, recovery dependencies and operational readiness.

## Publication review

- [ ] No passwords or credentials.
- [ ] No private repository endpoints.
- [ ] No employer data or configuration.
- [ ] No real personal data.
- [ ] Hostnames, addresses and identifiers sanitised where necessary.
