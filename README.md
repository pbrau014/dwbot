# DWBOT

World of Warships tournament Discord bot (YoloDiscordBot V4).

## Project state

The repository was created as a private repository and is currently being initialized. The original V4 source archive and Iteration 21 evidence are preserved separately in the DWBOT project files. They have **not yet been imported into this repository**; do not treat this documentation-only initialization as an application build.

**Release decision: NO-GO for unattended production.**

## Non-negotiable project constraints

- Preserve the V4 architecture; no rewrite without evidence.
- Support Damage, Kills, Race, and Grand Yolo events, with seven slots per player per event.
- Preserve workbook-derived scoring, including the $12.49 regression case and Grand Yolo weight 0.9.
- Require all eight mandatory OCR fields; XP remains optional.
- Never silently accept an incorrect mandatory OCR value. Uncertain values require human correction.
- Keep PaddleOCR fallback disabled (`PADDLEOCR_FIELD_FALLBACK=0`).
- Keep SQLite single-instance operation until multi-process coordination is designed and tested.
- Keep Discord tokens, local `.env`, databases, user data, and secrets out of Git.

## Development workflow

Every iteration must include a written objective, scoped diff, tests, acceptance report, reproducible logs, SHA-256 manifest, rollback path, and explicit pass/fail decision. Unit tests alone do not establish production readiness.

See [PROJECT_STATUS.md](PROJECT_STATUS.md) and [ROADMAP.md](ROADMAP.md).
