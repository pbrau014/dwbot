# Iteration 21 overlay validation — 2026-10-26

## Source integrity

- Original archive: `YoloDiscordBotV4.zip`
- SHA-256: `b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899`
- This matches the exact base archive hash specified by `README-ITERATION21-PATCH.md` in the supplied Iteration 21 patch.
- Applied `DWBOT_ITERATION21_PATCH.zip` as an overlay to a temporary extracted copy of the archive.
- Verified every entry in `SHA256SUMS-ITERATION21.txt`: **21 entries, 0 mismatches**.

## Regression validation

Executed `npm test` on the patch-applied copy with Node.js **v24.17.0** and npm **11.13.0** under Linux. The existing dependency directory from the source archive was used; this was not a clean install.

| Result | Count |
|---|---:|
| Tests | 178 |
| Passed | 178 |
| Failed | 0 |
| Skipped | 0 |

The unit/regression suite passes for the patch-applied copy. The full real-image Tesseract.js acceptance sequence was not run in this validation, and this run does not replace target-Windows testing or an independent OCR holdout.

## Relevance to the owner-reported Windows output

The owner-reported console output states “all nine fields exactly”. That string is present in the Iteration 20 baseline file `scripts/run-additional-screenshot-regression.js`. The Iteration 21 overlay changes it to require all eight mandatory fields and explicitly treats XP as optional. The console output therefore strongly indicates that at least this runner had not been updated by the full overlay.

Next: apply the full overlay on Windows, verify the updated runner/test files, and rerun the clean install, unit suite, and real-image acceptance sequence before diagnosing the new report.
