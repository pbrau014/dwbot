# DWBOT release-gate runbook

**Purpose:** complete gates that cannot be established by Linux unit tests or the 16-image development corpus.  
**Release decision until every required gate has evidence:** **NO-GO for unattended production**.

## A. Independent OCR holdout (mandatory)

1. Collect at least 50 new screenshots (100 preferred) that have never been used for development, threshold selection, debugging, or patch decisions. Include different maps/modes, player names, battle results, reward layouts, crop/quality variation, confusable glyphs (`O/0`, `Q/O`, `I/l/1`), partial/low-quality images, and negative controls.
2. Before testing, compute SHA-256 for every image and freeze a manifest. Two reviewers independently record expected values for the eight mandatory fields (`result`, `player`, `map`, `mode`, `battleStart`, `credits`, `freeXp`, `damage`) and optional `xp`. Resolve reviewer disagreements before running OCR. Do not tune on these images afterward; if any holdout image is used to tune, retire it from the holdout and replace it.
3. Run the candidate once with Node.js v24.22.1 x64, `OCR_ENGINE=tesseractjs`, `PADDLEOCR_FIELD_FALLBACK=0`, `OCR_CV_ASSIST=0`, network blocking enabled, and fixed timeouts. Capture per-field predicted/expected values, accepted/held/rejected status, OCR source/crop evidence, elapsed time, process exit and blocked-network attempts.
4. Report mandatory field exactness, all-eight-exact records, false accepts, unresolved values, optional-XP accuracy separately, p50/p95 latency, timeouts and network attempts.
5. **Hard gate:** zero incorrectly accepted mandatory values and zero OCR/model external network attempts. Ambiguity must be held for correction. Aim for at least 95% all-eight-mandatory exact records as a usability goal, but never relax the zero-false-accept gate. Below the usability target remains NO-GO for unattended use.

## B. Authorized Discord staging

Use a staging guild/channels only, with an owner-controlled test bot token. Never commit `.env`, tokens, live databases, tournament data, private screenshots or unredacted logs.

Test all four event types (`Damage`, `Kills`, `Race`, `Grand Yolo`) and all seven player slots per event. Verify role/channel permissions, image attachment intake, invalid/unsupported files, duplicates, human correction and re-submission, auditability, retries, burst traffic, queue saturation, clean back-pressure, shutdown/restart, Discord reconnect, single-instance enforcement, errors, and scoring compatibility including the `$12.49` regression and Grand Yolo weight `0.9`.

Record each case's fixture ID, expected behavior, actual outcome, timestamp, sanitized log path and pass/fail. Do not use production guilds or real tournament data for this gate.

## C. Persistence and recovery rehearsal

1. Create a staging-only database with known fixture records. Record the pre-backup hash and row counts.
2. Test transaction rollback on injected failure, JSON recovery consistency, duplicate/retry behavior, shutdown/restart and single-instance lock behavior.
3. Back up database and recovery JSON using the documented procedure. Verify hashes and metadata.
4. Restore to a separate, initially empty location; never overwrite the source database in the drill. Verify SQLite `PRAGMA integrity_check`, schema version, row counts, fixture records and consistency with recovery JSON.
5. Repeat after simulating a partial/corrupt staging copy. Record detection and recovery; redact sensitive paths/tokens.

## D. Rollback rehearsal

1. Keep the last known-good package and manifest immutable.
2. Deploy candidate to a staging directory, verify its manifest, run startup/health check and one fixture event.
3. Trigger rollback to the known-good package; restore the pre-deployment staging snapshot if required.
4. Verify process health, database integrity, event intake, scoring and logs after rollback.
5. Confirm rollback does not require network downloads of OCR models or send OCR content/telemetry to external services.

## E. Evidence and sign-off

Each evidence package should include commands, runtime versions, effective non-secret configuration, input hashes, reports/logs, exit codes and a `SHA256SUMS` manifest. A failed command, missing report, blocked network attempt, missing ground truth, secret exposure or incorrect accepted mandatory value keeps the gate open.

| Gate | Required evidence | Status |
|---|---|---|
| exact historical base or approved re-baseline | Original archive hash, or formal approval + source manifest | Open |
| clean Windows acceptance | Node v24.22.1 x64, `npm ci`, `npm test`, `npm run test:tesseractjs`, full logs/hashes | Open |
| independent OCR holdout | 50+ frozen/reviewed new images; zero false mandatory accepts; zero network attempts | Open |
| Discord staging | All event types and seven slots plus permission/retry/recovery cases | Open |
| backup/restore | Separate-location restore, DB integrity, expected state verified | Open |
| rollback | Rehearsal result and post-rollback health check | Open |

A Linux development-corpus pass does not close these external gates by implication. Do not promote to unattended production until all required evidence has been reviewed.