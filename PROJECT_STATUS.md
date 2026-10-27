# DWBOT project status

**Updated:** 2026-10-27  
**Release:** NO-GO for unattended production  
**Repository visibility:** GitHub currently reports `pbrau014/dwbot` as public. The repository README and prior status say private; this conflict is unresolved, and visibility was not changed.  
**Application source in GitHub main:** The authoritative application source has not been imported into `main`. The verified source candidate and test evidence below are held in the local handoff workspace.

## Latest verified local candidate — Iteration 23

The V4 source archive and Iteration 21 patch were rechecked against their recorded SHA-256 values:

- V4 archive: `b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899`
- Iteration 21 patch: `35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14`

The latest saved Iteration 23 OCR report is tied to source-build fingerprint `6c87a4446e080b4243f4ff0eda54b39008a33af8b1a1eb7bad74846fbc0b82ef` (72 source files), Windows Node.js v24.22.1 x64, and report SHA-256 `909E3EC196408BD07DD6C5EB16A532D165C66808569AA0C33B9FC28F893794A9`.

It processed all 16 development images with network blocking enabled:

- Mandatory fields exact: **110/128**
- Records exact across all eight mandatory fields: **7/16**
- Mandatory fields unresolved: **18**
- Incorrectly accepted mandatory values: **0**

These are development-corpus results, not an independent holdout. The unresolved fields remain unresolved; approved ground truth has not been changed. The 93-image diagnostic corpus has no verified ground-truth labels and does not establish accuracy.

## Test and PR status

Saved local test logs for the current candidate report 179 total tests (176 passed, 0 failed, 3 skipped); they are not a fresh clean-install acceptance run. PR #2's 185/185 claim refers to its separate candidate and must not be combined with these results.

PR #2 remains open, draft, and unmerged at head `ec968646f2db0dfea1674cb87f63ae83138d6ea8`. Its 24 changed files are documentation, evidence, and patch artifacts; they do not import the application source. The PR description predates the verified Iteration 23 report. A review comment was added identifying that the acceptance guide references a runner missing from the PR head and overstates the runner's safeguards. GitHub would not accept a formal “request changes” review from the PR author account.

## Remaining gates

1. Diagnose the 18 unresolved values using development/tuning images only; preserve approved ground truth and the zero-false-accept rule.
2. Freeze at least 50 new, never-tuned screenshots (100 preferred), hash them, obtain two independent labels for the eight mandatory fields and optional XP, reconcile disagreements before OCR, then run once. Any image used for tuning must be retired and replaced.
3. Run a fresh clean Windows x64 acceptance sequence on Node.js v24.22.1, including `npm ci`, `npm test`, and `npm run test:tesseractjs`; preserve logs, reports, hashes, runtime versions, exit codes, and network-block evidence.
4. Complete authorized Discord staging, persistence/recovery, backup/restore, and rollback checks.
5. Keep unattended production **NO-GO** until the independent holdout reports zero incorrectly accepted mandatory values and zero OCR/model network attempts, and all other release gates are reviewed.

Do not treat the saved development-corpus result or unit-test counts as independent accuracy evidence.
