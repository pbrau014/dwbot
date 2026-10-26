# DWBOT project status

**Updated:** 2026-10-26  
**Release:** NO-GO for unattended production  
**Repository:** private, `pbrau014/dwbot`  
**Repository initialization:** documentation only; source import remains pending.

## Verified prior baseline

Iteration 21 is recorded as passing **178/178 automated tests**. This result is historical evidence from the preserved working copy; it has not been reproduced from this repository because the application source has not yet been imported.

Iteration 21 addressed:
- Correct separation of eight mandatory fields from optional XP.
- Rejection of undecodable replacement characters (`�`).
- Regression tests for those acceptance rules.

The paired Windows OCR benchmark showed Tesseract.js alone outperforming the Tesseract.js + PaddleOCR hybrid:

| Metric | Tesseract.js | Hybrid |
|---|---:|---:|
| Exact mandatory fields | 111/128 | 108/128 |
| Fully exact mandatory records | 7/16 | 3/16 |
| Incorrect accepted mandatory fields | 2 | 4 |
| Unresolved mandatory fields | 15 | 16 |
| Median latency | 34,898 ms | 42,601 ms |

**Decision:** do not enable PaddleOCR. The 16-image corpus is a development/tuning corpus, not an independent holdout.

## Next gates

1. Import the exact V4 source baseline and apply the Iteration 21 patch as an overlay; preserve the original archive and verify its SHA-256 manifest.
2. Review the resulting repository tree for secrets, local databases, generated data, installers, and oversized/unnecessary assets before committing.
3. Reproduce clean Windows Node.js 24.22.1 installation and test results (`npm ci`, `npm test`, OCR tests).
4. Compare native Tesseract and Tesseract.js on the same frozen Windows corpus; pin the selected engine explicitly.
5. Create a genuinely independent holdout. Hard safety gate: zero incorrectly accepted mandatory fields.
6. Complete Discord staging, permissions, correction workflow, duplicate handling, restart/reconnect, SQLite backup/restore, JSON recovery, clean deployment, and rollback rehearsals.

## User/local-host actions eventually required

Live Discord validation requires the bot owner to run with a local token in `.env`; never commit or share that token. Windows OCR and Discord staging gates cannot be honestly claimed as passed from a Linux-only run.
