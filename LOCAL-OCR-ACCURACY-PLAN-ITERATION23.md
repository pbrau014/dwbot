# Local-only OCR accuracy plan — Iteration 23

**Selected path:** Accuracy and safety first.  
**Privacy constraint:** All image processing stays local/offline. No external OCR, AI, telemetry, or image upload. Cloud fallback is out of scope unless the owner explicitly changes this requirement.  
**Release posture:** NO-GO for unattended production.

## Source-of-truth blocker

The connected repository currently contains project documentation, evidence and patch artifacts, but not the authoritative application source (`package.json`, `src/`, scripts, fixtures and local model assets are absent on the working branch). The original V4 archive is referenced by prior evidence but is not present in this repository. Therefore no application implementation should be claimed until the exact source ZIP is imported and its manifest verified. The next source-dependent step is to obtain the owner’s authoritative V4 ZIP plus the full Iteration 21 overlay, preserve both immutably, and validate their SHA-256 manifests before applying any new code.

## P0 — Freeze baseline and diagnose geometry

1. Import exact V4 source and the complete Iteration 21 overlay to a separate candidate branch. Verify all archive and patch hashes; do not edit ground truth.
2. Pin Node.js 24.22.1 x64 for target acceptance. Record OS, npm, architecture, ImageMagick/OpenCV runtime and model hashes.
3. Run existing unit suite and Tesseract.js acceptance unchanged before code edits.
4. Produce a frozen fixture manifest with image SHA-256, approved expected fields, source split (development/tuning/holdout), layout dimensions and known defect labels.
5. For each known failure, render and inspect original image + proposed crop overlay. Record x/y/width/height, scale, anchor/template used, and whether each digit/label is clipped or neighboring fields leak into the crop.
6. Keep OpenCV strictly in the geometry proposal/quality-check stage. It may propose and score crop rectangles, but it must not decide field values or authorize an OCR candidate.
7. Add geometry tests: crop in bounds, non-empty, adequate margin, no field overlap, stable anchor offsets across supported resolutions, no leading/trailing glyph clipping. Save derived crops separately; never modify originals.

## P1 — Local engine interface and PaddleOCR benchmark

1. Preserve Tesseract.js as default and baseline. PaddleOCR is optional and disabled by default.
2. Use a supervised local Python worker only if package/model compatibility and offline packaging are verified. No HTTP service, cloud endpoint or API key. Worker input/output should be bounded local JSON/stdio with explicit timeout, max image bytes, clean shutdown, and no network dependency.
3. Pin Python, PaddleOCR, PaddlePaddle, OpenCV, and PP-OCR model versions; record license, model origin, hashes, CPU/GPU requirements, Windows support, cold-start latency, resident memory and package size. Download model assets only during an explicit setup step; runtime must work offline.
4. Feature flags: `OCR_ENGINE=tesseractjs` by default; `PADDLEOCR_FIELD_FALLBACK=0` by default; explicit opt-in for benchmark runs. No automatic switch to Paddle until measurements support it.
5. Benchmark A) existing Tesseract.js; B) OpenCV-isolated Tesseract.js; C) OpenCV-isolated Tesseract.js + selective local PaddleOCR; D) evidence-based selection/human review. Use identical images, crops and ground truth; separate raw OCR from integrated pipeline results.
6. Treat same pixels, repeated PSMs and crop variants as correlated evidence. Require genuine independent support or leave the critical field unresolved. Never select the largest number or raw highest confidence alone.

## P2 — Acceptance and error analysis

Report numerator/denominator explicitly for every metric:
- Per-field exactness for eight mandatory fields and optional XP separately.
- Complete mandatory record exactness.
- Incorrectly accepted mandatory field count/rate (hard gate: zero).
- Unresolved fields and human-review rate.
- False rejection, by-field/category errors, timeouts/exceptions.
- p50/p95 latency, throughput, CPU/RAM, model cold-start and package footprint.
- Repeatability across sequential batches and reversed input order.
- Network audit: zero OCR/model network attempts in local-only mode.

Development/tuning images are never reported as independent holdout. Freeze 50+ new images (100–200 preferred) and reviewed ground truth before final holdout. If any holdout image is used to tune code, retire and replace it.

## P3 — Human review and record safety

- A missing/conflicting required value remains unresolved and cannot enter an accepted scoring record.
- Preserve competing candidates, crop coordinates, engine/model/version, raw text, parsed value, validation results, rejection reasons and final decision.
- Human correction must be explicit and auditable; do not silently replace a name with a roster-nearest match.
- Keep existing scoring, events, seven slots, Discord behavior, SQLite single-instance constraints and data contracts unchanged.

## P4 — Release gates

1. Exact final source hash and package manifest.
2. Clean `npm ci` and all tests on Windows x64 with Node 24.22.1.
3. Local model/assets verified offline; Paddle remains disabled by default unless proven beneficial.
4. Zero incorrect mandatory accepts on independent holdout and zero network attempts.
5. Discord staging, permissions, retries, shutdown/reconnect, persistence, backup/restore and rollback rehearsal.
6. Produce a sanitized ZIP and checksums. No .env, tokens, live DB, user data, node_modules, .git or cached personal state.

## Current evidence and honest limitations

Prior recorded benchmark (16-image development corpus): Tesseract.js alone 111/128 mandatory fields exact, 7/16 all-eight-exact records, 2 incorrect accepted mandatory fields, 15 unresolved mandatory fields, median latency 34.9 s. Tesseract.js + Paddle hybrid 108/128 exact fields, 3/16 all-eight-exact records, 4 incorrect accepted mandatory fields, 16 unresolved, median latency 42.6 s. The hybrid regressed and must remain disabled. This is development evidence only, not an independent holdout.

Iteration 22 candidate reports improved some targeted cases and conservative identity handling, but the final corrected full formal run did not yet finish in the visible log and earlier 16-image runs had unresolved records and optional XP discrepancies. Do not claim the final formal acceptance passed until the exact report is reviewed. Clean-install registry DNS, Windows acceptance, independent holdout, live staging, backup/restore and rollback remain open.
