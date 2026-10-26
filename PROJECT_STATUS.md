# DWBOT project status

**Updated:** 2026-10-26  
**Release:** NO-GO for unattended production  
**Repository:** private, `pbrau014/dwbot`  
**Application source import:** still pending.

## Latest owner-reported Windows run

The owner ran `npm ci`, `npm test`, and `npm run test:tesseractjs` from the Windows V4 application folder on 2026-10-26. Detailed reported results are preserved in [Windows acceptance evidence](evidence/windows-acceptance-2026-10-26.md).

- `npm ci`: success in 11 seconds; 40 packages audited; 0 vulnerabilities.
- `npm test`: 174 tests; 171 passed, 0 failed, 3 skipped.
- `npm run test:tesseractjs`: **7/13 acceptance stages passed; 6 failed**.
- Additional screenshot corpus: 16 images completed; 6/16 exact, 8/16 complete-required-field records. The acceptance runner failed the stage.
- Repeated five-image and Hoffmann/Asashio sequence checks also failed.
- The runner printed summary SHA-256 `ef1e28f41351734dfa991399769a8985254c2f74bfbabdf6c3db6fba295920e6` for `acceptance-report.json`.

This makes the result clear: clean dependency installation and automated regression are positive, but real-image OCR acceptance is not passing. The exact Node/npm versions and effective `OCR_ENGINE` / `PADDLEOCR_FIELD_FALLBACK` environment values were not present in the pasted transcript, and the full JSON/logs have not yet been committed. Do not infer the target runtime from the directory or test output.

## Important acceptance-contract audit

DWBOT's policy defines eight mandatory fields and treats XP as optional. The printed acceptance message for the additional corpus says “all nine fields” must match exactly. The report schema/comparator must be audited to ensure optional XP does not affect required completeness, fully correct mandatory-record counts, mandatory review counts, or the false-acceptance gate. This contract check must not weaken the requirement that all eight mandatory fields are exact or explicitly corrected before acceptance.

Tracking issue: [#1 — Iteration 22: diagnose Windows OCR acceptance failures](https://github.com/pbrau014/dwbot/issues/1).

## Previously recorded baseline

The preserved Iteration 21 report records **178/178 tests passing** on its earlier working copy. The current owner-reported run is **171 passed, 0 failed, 3 skipped (174 total)**. These counts are from different recorded run contexts and should not be conflated; the exact source revisions and runtime versions need to be captured to reconcile them.

The Iteration 21 changes addressed:
- Separation of eight mandatory fields from optional XP.
- Rejection of undecodable replacement characters (`�`).
- Regression tests for those acceptance rules.

Earlier paired Windows benchmark results showed Tesseract.js alone outperformed the Tesseract.js + PaddleOCR hybrid:

| Metric | Tesseract.js | Hybrid |
|---|---:|---:|
| Exact mandatory fields | 111/128 | 108/128 |
| Fully exact mandatory records | 7/16 | 3/16 |
| Incorrect accepted mandatory fields | 2 | 4 |
| Unresolved mandatory fields | 15 | 16 |
| Median latency | 34,898 ms | 42,601 ms |

**Decision:** keep PaddleOCR disabled (`PADDLEOCR_FIELD_FALLBACK=0`). The known 16-image corpus is a development/tuning corpus, not an independent holdout.

## Next gates

1. Import the exact V4 source baseline and apply the Iteration 21 patch as an overlay; preserve originals and verify manifests.
2. Commit the full Windows acceptance report and run artifacts, including environment versions/configuration with secrets removed.
3. Audit the eight-required/XP-optional acceptance contract, then diagnose field-level mismatches (especially Libertad, Schlieffen, and Hoffmann).
4. Reproduce the run on the explicitly pinned target Windows Node.js 24.22.1 runtime, recording effective `OCR_ENGINE`, `PADDLEOCR_FIELD_FALLBACK`, model/asset hashes, and output report hashes.
5. Compare native Tesseract and Tesseract.js on the same frozen Windows corpus.
6. Create a genuinely independent holdout; unattended gate requires zero incorrectly accepted mandatory fields.
7. Complete Discord staging, permissions, correction workflow, duplicate handling, restart/reconnect, SQLite backup/restore, JSON recovery, clean deployment, and rollback rehearsals.

## User/local-host actions eventually required

Live Discord validation requires the bot owner to run with a local token in `.env`; never commit or share that token. The OCR acceptance artifacts should be copied from the generated `testdata/ocr-acceptance/...` folder into a sanitized evidence bundle before committing. Do not upload secrets, private user data, or an active database.
