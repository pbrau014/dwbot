# Windows acceptance for the DWBOT Iteration 22 candidate

This runbook is for the sanitized candidate ZIP, not the older pinned-source-only runner. It verifies `CANDIDATE-SHA256SUMS-2026-10-26.txt`, then runs the clean Windows acceptance sequence.

## Prerequisites

- Windows x64, Node.js **v24.22.1 x64**, npm and ImageMagick (`magick`) on PATH.
- Network access to npm registry for the clean install; OCR/model processing runs with a network-blocking preload.
- The sanitized candidate must exclude `.env`, live SQLite state, `node_modules`, and `.git`.

## Run

Extract the candidate ZIP, then from PowerShell use a new working output folder:

```powershell
node --version
node -p "process.arch"
npm.cmd --version
magick -version

powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\windows-candidate-acceptance.ps1 `
  -ProjectDirectory "C:\DWBOT\DWBOT_ITERATION22_CANDIDATE_2026-10-26" `
  -OutputRoot "C:\DWBOT\ACCEPTANCE_RUN_2026-10-26"
```

The script verifies every candidate manifest entry, checks the eight-mandatory-fields/optional-XP contract, refuses live secret/state files, then runs `npm ci --no-audit --no-fund`, `npm test`, and `npm run test:tesseractjs`. OCR config keeps `PADDLEOCR_FIELD_FALLBACK=0` and `OCR_CV_ASSIST=0`. Any blocked OCR/model network attempt is an acceptance failure.

Evidence is stored under `run-artifacts/`: command logs, fresh OCR reports, run metadata, blocked-network evidence, and a SHA-256 manifest. Preserve it intact.

This does not replace the independent 50+ screenshot holdout, authorized Discord staging, backup/restore, and rollback rehearsal. Production remains NO-GO until all gates pass.
