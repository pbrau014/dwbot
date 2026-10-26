# Iteration 21 Windows Acceptance Runbook

**Status:** prepared; execution is blocked until the exact V4 source archive is available.
**Release posture:** NO-GO for unattended production until the independent OCR holdout, Discord staging, and restore/rollback gates pass.

## Required inputs

1. Original `YoloDiscordBotV4.zip` with SHA-256:
   `b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899`
2. `DWBOT_ITERATION21_PATCH.zip` with SHA-256:
   `35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14`
3. Windows x64 with Node.js `v24.22.1`, npm, and ImageMagick (`magick`) on `PATH`.
4. The acceptance runner at `scripts/windows-iteration21-acceptance.ps1` from this repository branch.

Do not substitute a different source archive or patch. The runner stops before patching if either archive hash differs.

## Run

Open PowerShell in a working directory with enough disk space for two extracted archives, a clean npm install, and acceptance logs. Keep the original archives unchanged. Run:

```powershell
node --version
npm.cmd --version
node -p "process.arch"
magick -version

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows-iteration21-acceptance.ps1 `
  -SourceArchive "C:\DWBOT\YoloDiscordBotV4.zip" `
  -PatchArchive "C:\DWBOT\DWBOT_ITERATION21_PATCH.zip" `
  -OutputRoot "C:\DWBOT\DWBOT_ACCEPTANCE_ITERATION21"
```

Choose a new, nonexistent `OutputRoot` for each run. The runner intentionally refuses to overwrite an existing evidence directory.

## What the runner does

- Checks the exact source and patch SHA-256 values.
- Requires Node.js `v24.22.1` x64 and checks that ImageMagick is available.
- Extracts into a fresh output directory and applies only the 21 paths listed in `SHA256SUMS-ITERATION21.txt`.
- Verifies the overlay hashes both before and after copying.
- Verifies that the screenshot runner requires “all eight mandatory fields” and that an optional-XP regression test exists.
- Removes a root `.env` only from the isolated extracted test copy; it does not change the original archive.
- Runs `npm ci`, `npm test`, and `npm run test:tesseractjs` with:
  - `OCR_ENGINE=tesseractjs`
  - `PADDLEOCR_FIELD_FALLBACK=0`
  - `OCR_CV_ASSIST=0`
- Captures command logs, acceptance reports, run metadata, exit codes, and a SHA-256 evidence manifest under `run-artifacts`.

## Review the result

A zero exit code means the scripted install and acceptance commands completed; it does **not** authorize production by itself. Review:

- `run-artifacts/acceptance-run-meta.json`
- `run-artifacts/SHA256SUMS-ACCEPTANCE.txt`
- Per-command logs and copied OCR acceptance reports under `run-artifacts`

If the OCR acceptance run fails, preserve the evidence and diagnose field-level reports. Do not weaken mandatory-field acceptance or enable PaddleOCR fallback merely to increase completeness. The development 16-image corpus is not an independent holdout.

## Remaining release gates

1. Corrected Iteration 21 Windows run with reproducible evidence.
2. Field-level diagnosis and regression tests for any targeted fixes.
3. At least 50 new, frozen, independently reviewed screenshots (100 preferred), with **zero incorrectly accepted mandatory fields** and zero OCR/model external network attempts.
4. Discord staging across Damage, Kills, Race, Grand Yolo, and all seven player slots.
5. SQLite/JSON consistency, restart/recovery, backup restore to a separate location, and single-instance enforcement.
6. Clean deployment and rollback rehearsal with no secrets or live data committed.

Until every required gate is evidenced, the release decision remains **NO-GO**.
