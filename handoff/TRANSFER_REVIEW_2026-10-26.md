# DWBOT Transfer Review — 2026-10-26

**Observed main commit:** 8ea65294dfcf237b219fd68cd56ef9f86ffa1eff  
**Release decision:** NO-GO for unattended production

## Review outcome

The transfer package is internally consistent, but the app-source import remains the blocking prerequisite. The repository is still documentation-only; the Iteration 21 ZIP is an overlay, not a complete application. Do not import the overlay files by themselves or apply them to a guessed source revision.

### Integrity checks performed

- Transfer manifest: 17 of 17 files matched their recorded SHA-256 hashes.
- Iteration 21 overlay manifest: 21 of 21 files matched.
- Key artifact hashes: patch ZIP, unified diff, test log, production-readiness plan, and acceptance report all matched (5 of 5).
- Required V4 base archive SHA-256: b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899.
- Patch archive SHA-256: 35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14.

The source archive itself was not present in the supplied transfer ZIP. The external Drive ZIP and ChatGPT project conversations could not be read in this session; they are not treated as reviewed evidence.

## Evidence interpretation

- Iteration 21 regression tests: 178 passed, 0 failed, 0 skipped on Linux with Node 24.17.0; the run reused the existing dependency directory and did not complete real-image OCR acceptance.
- Owner-reported Windows run: 171 passed, 0 failed, 3 skipped from 174 tests. The OCR sequence passed 7 of 13 stages and the 16-image sequence reported 6 of 16 exact and 8 of 16 complete required-field records.
- The Windows output printed the Iteration 20 rule (“all nine fields exactly”), not the Iteration 21 rule (“all eight mandatory fields”). Treat the output as a pre-patch or incomplete-overlay baseline.
- The earlier benchmark showed the Tesseract.js + PaddleOCR hybrid produced fewer exact mandatory fields, fewer fully correct records, more incorrect accepted mandatory values, and worse median latency than Tesseract.js alone. Keep PADDLEOCR_FIELD_FALLBACK=0.

## Non-negotiable behavior

1. Preserve the V4 architecture and workbook scoring, including the $12.49 regression case and Grand Yolo weight 0.9.
2. Support Damage, Kills, Race, and Grand Yolo; seven slots per event.
3. Require exactly these eight mandatory OCR fields: result, player, map, mode, battleStart, credits, freeXp, damage. XP is optional and diagnostic.
4. Never silently accept an incorrect mandatory value; ambiguous values must be held for human correction.
5. Reject Unicode replacement character U+FFFD in OCR/manual text.
6. Keep OCR/model processing local; OpenCV may suggest bounded crop geometry only.
7. Keep SQLite single-instance, validate JSON recovery consistency, and never commit tokens, .env, databases, live data, or secrets.

## Implementation sequence

### P0 — Pin source
Obtain YoloDiscordBotV4.zip, verify the exact base SHA-256 above, preserve the archive, and extract a clean working copy.

### P1 — Apply Iteration 21
Apply only the 21 files named in the overlay manifest, verify hashes after copy, and confirm the runner says “all eight mandatory fields” with optional-XP regression tests present.

### P2 — Windows acceptance
On target Windows x64 with Node 24.22.1, record node/npm/OS/architecture. Verify ImageMagick; use a clean npm ci; set OCR_ENGINE=tesseractjs, PADDLEOCR_FIELD_FALLBACK=0, and OCR_CV_ASSIST=0 for the pinned baseline; run npm test and npm run test:tesseractjs. Preserve full JSON/logs and SHA-256 manifest.

### P3 — Diagnose; do not weaken the gate
Inspect field-level reports for Libertad, Schlieffen, Hoffmann, Asashio, and the additional corpus. Compare native Tesseract and Tesseract.js on identical frozen inputs. Changes require targeted regression coverage.

### P4 — Independent holdout
Freeze a separately reviewed, hashed holdout of at least 50 new screenshots (100 preferred) before candidate scoring. Require zero incorrectly accepted mandatory fields and zero external network attempts. Every record must be exact on all eight required fields or explicitly held for correction. Target 95% fully exact records as a usability metric, never by lowering the safety threshold.

### P5 — Discord and persistence staging
Test all four event types and seven slots, permissions/channel boundaries, attachments, correction/duplicate/retry/burst handling, restart/reconnect, graceful shutdown, single-instance enforcement, SQLite/JSON consistency, and restore to a separate location.

### P6 — Release/rollback
Build a curated package, prove clean install/local assets/redacted logs/health checks/backup retention, rehearse rollback and restore, then record an explicit GO, supervised-pilot, or NO-GO decision.

## Exit criteria

Do not approve unattended production until the exact source is identified; Iteration 21 overlay and target-Windows tests pass; the independent holdout has zero false accepts and zero network attempts; Discord staging and restore rehearsal pass; and a rollback-ready package is verified. If usability is inadequate despite zero false accepts, remain NO-GO for unattended operation and consider only a supervised, human-confirmation pilot.

## Tracking

Continue the Windows acceptance work in issue #1: https://github.com/pbrau014/dwbot/issues/1
