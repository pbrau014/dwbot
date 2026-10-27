# Candidate validation for the updated V4 bundle (2026-10-26)

## Summary

An isolated Iteration 21 candidate was prepared from the user's uploaded `updated_discord_bot_and_latest_artifactsV4.zip`. The patch's declared hash and 21-file overlay manifest are valid. The candidate's complete unit suite passes after a narrow test-isolation correction. **This does not satisfy source identity or release acceptance gates; status remains NO-GO.**

## Input and source identity

- Uploaded bundle SHA-256: `f10db7f20da54dacf56ae497420a20ed64d1b890dae0078178891468669cc184`.
- Required original `YoloDiscordBotV4.zip` SHA-256: `b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899`.
- The upload has the project source as a directory, but does not contain the original `YoloDiscordBotV4.zip`; exact base-archive identity therefore remains unverified.
- The included `SOURCE-SHA256-MANIFEST.json` has 378 entries; 374 match the bundled source and four synthetic-validation JSONs differ.
- The included project `SHA256SUMS.txt` has 299 entries; 24 differ from the currently bundled tree. These discrepancies must be reconciled or superseded by an explicitly approved new baseline before production promotion.
- Iteration 21 patch SHA-256 verified as `35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14`.
- The 21 overlay payload hashes passed verification. The Iteration 21 unified diff passed `git apply --check` and applied to an isolated copy without hunk conflicts. This is a compatibility check, not proof of the missing original archive hash.

## Tests performed

- `npm test`: **178 passed, 0 failed, 0 skipped** on Node.js v22.16.0 / npm 10.9.2, using the bundle's existing `node_modules`. This is a diagnostic run, not a clean install or target-runtime acceptance.
- The first suite run with `OCR_CV_ASSIST=0` exposed a test-isolation bug: a test intended to exercise the OpenCV helper inherited the disabled baseline setting. A candidate-only test change now enables OpenCV within that one test and restores the previous environment. Production behavior was not changed by this test fix.
- `npm ci --offline --no-audit --no-fund` did not complete because `zlibjs@0.3.1` is not in the local npm cache and network resolution is unavailable. The current container also has Node v22.16.0, below the project engine requirement (`>=24.17.0`).
- A targeted OCR regression command timed out at the 120-second command limit without producing a valid report. It is not a pass.
- No clean Windows Node v24.22.1 run, independent holdout, live Discord staging, backup restore, or rollback rehearsal was completed.

## Sanitized candidate artifact

Prepared `DWBOT_ITERATION21_CANDIDATE_SAFE_2026-10-26.zip` (SHA-256 `8789a98ca4ef4557528b22416b08cd12523ce4ebfb15ea4cad2a1145d7b443ef`). The candidate manifest verifies 413 entries. The package excludes `.env`, the live `data/tournament-state.sqlite`, and `node_modules`. It contains the Iteration 21 diff plus the test-only OpenCV environment-isolation correction and validation evidence. It is for review/Windows validation only, not production deployment.

## Security note

The uploaded source bundle included a populated `.env` / `DISCORD_BOT_TOKEN` entry. The secret was not printed or committed and was excluded from the candidate. Rotate the Discord bot token before future live use; keep the replacement in the owner-managed local `.env` only.

## Remaining gates

1. Verify the exact original V4 archive or approve a new source baseline and regenerate manifests.
2. Run clean `npm ci`, `npm test`, and `npm run test:tesseractjs` on Windows x64 with Node v24.22.1 and ImageMagick; preserve full reports/logs/hashes.
3. Diagnose OCR failures without weakening mandatory-field acceptance; keep `PADDLEOCR_FIELD_FALLBACK=0`.
4. Evaluate on at least 50 new independent screenshots (100 preferred), double-review the ground truth, and require zero incorrectly accepted mandatory values and zero OCR/model external network attempts.
5. Complete Discord staging for all four event types and seven slots, persistence/restart/recovery tests, backup restore to a separate location, and rollback rehearsal.

Unattended production remains **NO-GO** until every gate is evidenced.