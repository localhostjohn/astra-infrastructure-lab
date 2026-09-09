# Raspberry Pi Backup and Recovery Validation

**Evidence date:** 9 September 2026  
**Workstream:** Astra Raspberry Pi operations and recovery  
**Source:** Sanitised transcription of the maintainer's actual terminal output  
**Scope:** Personal lab only; no employer infrastructure or real customer data.

## Objective

Verify that the scheduled encrypted Azure backup produces a Restic snapshot, that retention can be reviewed without deleting snapshots, and that a disposable file can be restored into an isolated directory and compared with its original. Repository integrity and full application recovery are separate checks.

## Scheduled backup — Passed

The systemd journal showed the 02:00 BST backup on 9 September completing successfully. The backup process verified the captured `kuma.db` and `app.db` files, captured application files and deployment definitions, and uploaded an encrypted snapshot to the Azure-backed Restic repository. Restic reported 620 files processed, approximately 103.971 MiB of source data, and a saved snapshot. A subsequent repository listing returned six snapshots. The service exited successfully at 02:00:10 BST.

**Interpretation:** The observed backup job and repository access succeeded. This does not establish that every application can be restored consistently or that every historical backup is intact.

## Retention dry run — Passed

The 03:00 BST retention service completed successfully on 9 September. The configured policy retained seven daily, four weekly and six monthly snapshots, plus baseline-tagged snapshots. The dry run identified one snapshot that would be removed and reported that no snapshots were deleted.

**Interpretation:** Policy evaluation and the non-destructive dry run succeeded. Actual pruning was neither requested nor performed. The observed retention outcome should not be treated as proof of future storage usage or recovery coverage.

## Repository integrity — Outstanding

The weekly timer was enabled and active, with its next scheduled trigger at 04:00 BST on Sunday, 13 September 2026. The oneshot service had not yet run and its journal contained no entries. Its reviewed script loads the private backup configuration, obtains a non-blocking lock and executes `restic check`. The service uses a two-hour timeout.

**Status:** Configuration reviewed; no successful integrity-check result claimed. The private environment and repository configuration were not published.

## Isolated restore — Passed

The maintainer confirmed an existing disposable baseline snapshot dated 8 September 2026 containing one 36-byte test file. Restic successfully restored the snapshot into a newly created temporary directory under `/tmp`, preserving its original directory structure beneath that target. The restore reported five files/directories and 36 bytes restored.

The restored file contained the expected test text. Its SHA-256 digest was:

```text
272515ea54f9d9e03372097f22f973395e73d8f9560688b949973227db18519a
```

The maintainer then calculated SHA-256 hashes for both the original and restored files. Both digests matched, and a byte-for-byte comparison using `cmp -s` returned:

```text
PASS: Restored file matches the original.
```

**Result:** PI-08 passed for this disposable dataset. No live application data was overwritten, and no retention, pruning or deletion operation was performed. The temporary restore directory was left in place pending normal lab housekeeping.

## Evidence boundaries and lessons learned

This test establishes that the selected snapshot could be retrieved and its test file restored with identical contents. It does not prove that all snapshots are readable, that an application database is consistent, that a complete service can be rebuilt, or that recovery-time and recovery-point objectives have been met. Those require separate exercises.

The exercise demonstrates the distinction between successful backup execution, retention policy evaluation, repository integrity and actual data recovery. The next recovery milestone is a controlled application-level restore using disposable or appropriately isolated data, with a documented recovery procedure and measured outcome.

## Remaining validation

- Record an actual repository integrity-check result after its scheduled run or an explicitly approved manual check.
- Complete the current host, container, storage and monitoring baseline.
- Test application-level recovery in an isolated environment before making any broader recoverability claim.
- Review backup scope, encryption-key recovery and retention requirements without publishing secrets or private infrastructure details.

No raw environment files, credentials, private repository URLs, real network addresses, backup archives or employer details are included in this evidence record.
