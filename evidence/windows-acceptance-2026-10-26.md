# Windows acceptance run — 2026-10-26

**Result:** automated unit/contract regression passes; screenshot-to-record OCR acceptance fails.  
**Release decision:** NO-GO for unattended production.  
**Evidence source:** console output pasted by project owner into the DWBOT development conversation. The full raw runner logs and JSON report were not attached to this record, so only reported excerpts and the summary hash below are available here.

## Environment and clean install

Working directory reported as the V4 application folder `wows-yolo-tournament-discord-bot` on Windows PowerShell.

- `npm ci`: completed successfully in 11 seconds.
- npm audit summary: 40 packages audited, 0 vulnerabilities.
- `npm test`: 174 tests total; 171 passed, 0 failed, 3 skipped; about 1.75 seconds.
- Skips shown: two POSIX-specific process-group fixtures, and optional OpenCV fixture because local Python/OpenCV was unavailable. This does not indicate a failed main test.
- `npm run test:tesseractjs`: completed the acceptance runner and generated a report directory beginning `testdata/ocr-acceptance/2026-10-26T16-31-02-338Z-13404/`.
- Runtime versions and full effective OCR environment/configuration were not included in the pasted output, and are not inferred here.

## Acceptance stage summary

The runner reported **7 of 13 acceptance commands passed** and **6 failed**. It reported no blocked network attempts.

Passing stages included unit/contract tests (94 pass, 0 fail), local OCR asset presence, the known-good Asashio negative-control baseline, the deliberately wrong expected-value negative control, stall-recovery lifecycle, integrated reported-screenshot exactness, and the reported-screenshot no-network check.

Failing stages included:
- Three repeated five-image sequences. Outcomes varied by run; repeated problems included `libertad-victory.jpg` and `schlieffen-defeat.jpg`. One report showed only 2/5 exact and 4/5 with required fields complete.
- Both two-image orders involving `hoffmann-victory.png` and `asashio-defeat.jpg`; Asashio passed but Hoffmann did not match expected values.
- The 16-image additional screenshot corpus: **16/16 images completed**, but only **6/16 were exact** and **8/16 had complete required fields**. The acceptance command failed.

The acceptance summary printed this SHA-256 for `acceptance-report.json`:

`ef1e28f41351734dfa991399769a8985254c2f74bfbabdf6c3db6fba295920e6`

This hash is recorded from console output; the JSON itself was not available for independent re-hashing.

## Important acceptance-contract question

The final additional-corpus message states that every image must match **all nine fields** exactly. DWBOT's current policy is **eight mandatory fields; XP is optional**. Before interpreting the exactness failures, inspect the actual report schema and comparator to confirm that optional XP is excluded from:
- required-field completeness,
- fully correct mandatory-record counts,
- required-field review counts,
- the hard false-acceptance gate.

Do not weaken the eight mandatory-field exact-match or false-acceptance safety rules. Correct any benchmark-contract mismatch separately from real OCR errors.

## Required follow-up

1. Preserve the generated acceptance folder including `acceptance-report.json`, per-stage logs, per-image JSON reports, and runtime/configuration metadata as a run artifact.
2. Inspect the comparator/runner and report schema against the eight-required/XP-optional contract.
3. Compare failing image ground truth to OCR candidates and field-level diagnostics. Do not accept confident-looking values when sources conflict.
4. Repeat deterministic sequences after any scoped change and compare on the same configuration.
5. Keep Tesseract.js explicitly pinned for reproducibility, and keep `PADDLEOCR_FIELD_FALLBACK=0`.
6. After diagnosis/tuning, validate on an independent holdout that was not used for tuning. Hard unattended-production gate remains zero incorrectly accepted mandatory fields.

## Scope and caveats

This is a Windows host run, as reported by the owner, but the transcript omitted the exact `node --version`, `npm --version`, effective `OCR_ENGINE`, and `PADDLEOCR_FIELD_FALLBACK` values. No claim is made that the results came from Node.js 24.22.1 or that all acceptance stages are correct for the current source revision until those details are captured.
