# DWBOT development roadmap

## Phase 0 — source-of-truth repository

- [ ] Import original YoloDiscordBot V4 source archive.
- [ ] Verify all source manifest hashes before edits.
- [ ] Apply Iteration 21 patch as an overlay and verify its manifest.
- [ ] Keep original archives and evidence immutable.
- [ ] Review repository hygiene and add CI for supported Node.js versions.

## Phase 1 — reproducible regression

- [ ] Clean `npm ci` on Windows Node.js 24.22.1.
- [ ] Run full `npm test` and OCR-specific suites.
- [ ] Preserve complete logs, runtime versions, configuration (without secrets), and SHA-256 manifests.
- [ ] Confirm workbook scoring regression ($12.49) and all event/slot workflows.

## Phase 2 — OCR safety and acceptance

- [ ] Keep PaddleOCR disabled.
- [ ] Keep OpenCV limited to bounded crop proposals; it must not recognize or authorize values.
- [ ] Compare native Tesseract and Tesseract.js on identical Windows screenshots, crops, thresholds, and configuration.
- [ ] Report mandatory-field exactness, fully exact records, false accepts, unresolved values, optional XP separately, and p50/p95 latency.
- [ ] Freeze a genuinely independent holdout before further tuning.
- [ ] Require zero incorrectly accepted mandatory fields. If automation usability is below target, use supervised human confirmation rather than relaxing the safety gate.

## Phase 3 — Discord and persistence staging

- [ ] Exercise all four events and seven slots.
- [ ] Test roles, permissions, public channel boundary, attachment intake, corrections, duplicates, retries, bursts, and queue limits.
- [ ] Test restart/reconnect and graceful shutdown.
- [ ] Verify SQLite/JSON consistency and single-instance enforcement.
- [ ] Rehearse backup and restore to a separate location.

## Phase 4 — release readiness

- [ ] Produce a curated deployable package with no secrets or live data.
- [ ] Validate clean installation, local assets, logging/redaction, health checks, backup retention, and rollback.
- [ ] Record all source/runtime/configuration/dataset hashes.
- [ ] Publish explicit GO / supervised-pilot / NO-GO decision.

## Iteration discipline

Each iteration requires an objective, scope, source diff, automated tests, acceptance report, reproducible logs, SHA-256 manifest, rollback instructions, and a release decision. No production approval from unit tests alone.
