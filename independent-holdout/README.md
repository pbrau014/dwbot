# Independent OCR holdout intake

Use this directory only for new images not used during development or tuning. The existing 16-image set is a regression corpus and must not be copied into the independent holdout.

## Required protocol

1. Collect 50 screenshots minimum (100 preferred). Keep originals immutable.
2. Hash each original image with SHA-256 and populate `ground-truth-template.csv` with a stable ID and relative path.
3. Two reviewers independently transcribe the eight required fields and optional `xp` from the image before seeing OCR output. If they disagree, adjudicate against the original and record the adjudicator/reason before freezing the dataset.
4. Include multiple event results, maps/modes, ship rewards, names with O/0/Q and I/l/1 confusables, varying image quality/crops, and negative controls.
5. Freeze the manifest and ground truth before running a candidate. If an image is inspected for debugging or used to change code/thresholds after the first candidate run, retire it from holdout and replace it with a new hashed image.
6. Run on the frozen holdout once with `OCR_ENGINE=tesseractjs`, `PADDLEOCR_FIELD_FALLBACK=0`, `OCR_CV_ASSIST=0`, Node.js 24.22.1 x64, local model assets, and network blocking. Record per-field accepted/held/rejected status, candidate/crop/source evidence, p50/p95 latency, timeouts and any blocked network attempts.
7. Pass only with zero incorrectly accepted mandatory fields and zero OCR/model network attempts. Unresolved mandatory fields are safer than a wrong accepted value, but count against the separate usability target; target at least 95% all-eight exact records for unattended operation.

Use a separate path from `fixtures/` so development tests do not accidentally consume holdout data. Do not include secrets, account data, or unrelated personal data in screenshots/logs.
