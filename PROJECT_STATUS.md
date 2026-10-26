# DWBOT project status

**Updated:** 2026-10-26  
**Release:** NO-GO for unattended production  
**Repository:** private, `pbrau014/dwbot`  
**Application source import:** still pending.

## Latest owner-reported Windows run

The owner ran `npm ci`, `npm test`, and `npm run test:tesseractjs` from the Windows V4 application folder. The detailed output is preserved in [Windows acceptance evidence](evidence/windows-acceptance-2026-10-26.md).

- `npm ci`: success; 40 packages audited; 0 vulnerabilities.
- `npm test`: 174 total, 171 passed, 0 failed, 3 skipped.
- `npm run test:tesseractjs`: 7/13 stages passed; 6 failed.
- The additional 16-image sequence reported 6/16 exact and 8/16 complete-required-field records, and repeat sequences had failures.
- Summary SHA-256 printed for `acceptance-report.json`: `ef1e28f41351734dfa991399769a8985254c2f74bfbabdf6c3db6fba295920e6`.

## Source-revision finding

The latest output printed “all nine fields exactly”, which matches the original Iteration 20 runner in the V4 archive. The Iteration 21 overlay changes that gate to **eight mandatory fields**, reports XP separately as optional, and adds regression tests for the contract. The original V4 archive hash was verified against the patch's declared base hash. The most likely explanation is that the Windows run used the Iteration 20 runner or an incomplete/reverted overlay; it is not a valid test of the complete Iteration 21 patch.

In a separate Linux validation, the Iteration 21 overlay was applied to the exact archived base. All 21 patch-manifest entries matched their hashes, and `npm test` passed **178/178** under Node.js 24.17.0 and npm 11.13.0. The existing archived dependency directory was used; this was not a clean install, Windows acceptance run, or live OCR test.

See [Iteration 21 overlay validation](evidence/iteration21-overlay-validation.md). Tracking issue: [#1 — Iteration 22: diagnose Windows OCR acceptance failures](https://github.com/pbrau014/dwbot/issues/1).

## Required next action

Apply the complete Iteration 21 overlay on the Windows working copy after making a backup. Confirm that `scripts/run-additional-screenshot-regression.js` now says “all eight mandatory fields” and that the optional-XP regression test is present. Then run a clean `npm ci`, `npm test`, and `npm run test:tesseractjs` again, pinning `OCR_ENGINE=tesseractjs` and `PADDLEOCR_FIELD_FALLBACK=0`. Capture the actual Node/npm versions and preserve the full report JSON and logs.

This does not mean OCR accuracy is fixed. It means the earlier acceptance output likely tested the old acceptance contract. After the corrected run, genuine field-level errors still require diagnosis, then an independent holdout.

## Previously recorded OCR benchmark

The earlier paired Windows comparison showed Tesseract.js alone outperforming the Tesseract.js + PaddleOCR hybrid:

| Metric | Tesseract.js | Hybrid |
|---|---:|---:|
| Exact mandatory fields | 111/128 | 108/128 |
| Fully exact mandatory records | 7/16 | 3/16 |
| Incorrect accepted mandatory fields | 2 | 4 |
| Unresolved mandatory fields | 15 | 16 |
| Median latency | 34,898 ms | 42,601 ms |

**Decision:** keep PaddleOCR disabled (`PADDLEOCR_FIELD_FALLBACK=0`). The existing 16-image corpus is a development/tuning corpus, not an independent holdout.

## Remaining gates

1. Import the exact V4 source baseline and apply Iteration 21 as a verified overlay; keep the original inputs immutable.
2. Record clean Windows install/test results with versions, configuration, logs, and SHA-256 hashes.
3. Audit the mandatory/optional acceptance schema and diagnose field-level OCR errors.
4. Compare native Tesseract and Tesseract.js on the same frozen corpus.
5. Require zero incorrectly accepted mandatory values on an independent holdout before unattended production.
6. Complete Discord staging, permissions, correction workflow, duplicate handling, restart/reconnect, SQLite backup/restore, JSON recovery, clean deployment, and rollback rehearsals.

Live Discord validation requires the owner to keep the bot token in a local `.env` only. Never commit secrets, active databases, or live user data.
