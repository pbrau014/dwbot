# Windows acceptance run — 2026-10-26

**Release decision:** NO-GO for unattended production.  
**Evidence source:** console output pasted by the project owner. Full JSON/log files were not attached, so only the console excerpts and reported summary hash are recorded here.

## Owner-reported install and unit tests

Working directory: `wows-yolo-tournament-discord-bot` under Windows PowerShell.

- `npm ci`: completed successfully in 11 seconds.
- npm audit: 40 packages audited; 0 vulnerabilities.
- `npm test`: 174 tests total; 171 passed, 0 failed, 3 skipped.
- Skips in the output: two POSIX process-group fixtures and the optional Python/OpenCV fixture because Python/OpenCV was unavailable.
- `npm run test:tesseractjs`: 7 of 13 stages passed; 6 failed. The runner reported no blocked network attempts.
- Report directory: `testdata/ocr-acceptance/2026-10-26T16-31-02-338Z-13404/`.
- SHA-256 printed for `acceptance-report.json`: `ef1e28f41351734dfa991399769a8985254c2f74bfbabdf6c3db6fba295920e6`.

The exact Node/npm versions and effective `OCR_ENGINE` and `PADDLEOCR_FIELD_FALLBACK` values were not included in the pasted output. The JSON and per-stage logs were not available for independent inspection or re-hashing.

## Key finding: this run appears not to use the complete Iteration 21 overlay

A post-run comparison found a strong source-revision mismatch:

1. The console prints the literal error text **“every image must complete, match all nine fields exactly”**.
2. The verified Iteration 20 file in the original V4 archive contains that exact message.
3. The Iteration 21 patch changes the same line to **“all eight mandatory fields”** and explicitly says XP is optional and reported separately.
4. The original V4 archive SHA-256 matches the exact base hash named in the Iteration 21 patch README: `b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899`.
5. The user's test output has 174 tests; the Iteration 21 overlay adds regression coverage, and in our separate patched-copy regression run the suite reported 178/178 passing.

**Conclusion:** the Windows output is not evidence that the complete Iteration 21 acceptance-contract patch was tested. At minimum, the additional-screenshot runner in the tested folder is the old Iteration 20 version (or was reverted). Treat these OCR-stage results as a useful pre-patch baseline, not the final Iteration 21 acceptance result. This does not prove that the underlying OCR accuracy is good; the OCR stage must be rerun after applying and verifying the overlay.

## Reported real-image outcomes from this pre-patch run

- Three repeated five-image runs failed, with repeated problems including `libertad-victory.jpg` and `schlieffen-defeat.jpg`.
- Both two-image sequence orders involving `hoffmann-victory.png` and `asashio-defeat.jpg` failed; Asashio passed but Hoffmann did not match expected values.
- The additional 16-image sequence completed all images but reported only **6/16 exact** and **8/16 complete-required-fields**.

Those figures remain evidence of a failed pre-patch run. They should not be treated as corrected Iteration 21 metrics. The full run report is needed for field-level diagnosis.

## Independent overlay validation performed in this environment

The Iteration 21 patch README names the exact V4 base archive hash above, and that hash was independently computed and matched. I overlaid the patch onto an extracted copy of that archive and verified all **21 files listed in the patch SHA-256 manifest** with zero hash mismatches. Then `npm test` passed **178/178 tests** under Node.js **v24.17.0** and npm **11.13.0** in Linux using the source archive's existing dependency directory. This was a unit/regression run, not a clean `npm ci`, Windows run, or real-image OCR acceptance run.

## Next steps

1. On the Windows working copy, apply the overlay in `DWBOT_ITERATION21_PATCH.zip` to the exact V4 source tree, allowing the 18 same-path files to be overwritten. Do this only after making a backup.
2. Confirm the runner's source line now says “all eight mandatory fields” and identifies XP as optional.
3. Confirm the new optional-XP regression test exists, then run `npm ci` and `npm test`.
4. Run `npm run test:tesseractjs` again with explicit `OCR_ENGINE=tesseractjs` and `PADDLEOCR_FIELD_FALLBACK=0`. Capture runtime versions and effective config (no secrets).
5. Preserve the complete new acceptance folder and report JSON in the repository; then diagnose genuine field-level mismatches.
6. Only tune after the acceptance-contract is corrected, and validate on a separate independent holdout. Keep the zero-false-acceptance safety gate.

Do not enable PaddleOCR, relax mandatory field checks, or mark production GO based on this run.
