# Paired OpenCV-assisted vs Tesseract.js-only benchmark

**Date:** 2026-10-26  
**Scope:** 16 approved development fixtures; not an independent holdout.  
**Runtime:** Node.js v24.22.1 x64 / Tesseract.js 6.0.1 / tesseract.js-core 6.1.2 / local English model.  
**Offline safety:** network guard enabled in both runs; PaddleOCR fallback disabled in both.  
**Pair validity:** identical 80-file source fingerprint, fixture order, image hashes, runtime, and Tesseract versions; only `OCR_CV_ASSIST` changed.

## Result

OpenCV did **not** improve accuracy on this 16-image development set. It had the same mandatory-record exactness, all-field exactness, unresolved fields and false-accept count, while adding latency. The candidate now defaults `OCR_CV_ASSIST=0`; OpenCV remains optional for targeted experiments until boundary improvements show a measurable benefit.

| Metric | Tesseract.js only (`OCR_CV_ASSIST=0`) | OpenCV-assisted (`OCR_CV_ASSIST=1`) | Change |
|---|---:|---:|---:|
| Completed images | 16/16 | 16/16 | 0 |
| Exact mandatory records | 12/16 (75.0%) | 12/16 (75.0%) | 0 |
| Records complete on all mandatory fields | 12/16 (75.0%) | 12/16 (75.0%) | 0 |
| Exact records including optional XP | 10/16 (62.5%) | 10/16 (62.5%) | 0 |
| Incorrectly accepted mandatory fields | 0 | 0 | 0 |
| Median latency | 42.796 s | 44.010 s | +1.214 s |
| p95 latency | 53.017 s | 54.022 s | +1.005 s |
| Network attempts observed | 0 | 0 | 0 |

## Exact field rates

| Field | Exact / 16 | Accuracy |
|---|---:|---:|
| result | 16/16 | 100% |
| player | 14/16 | 87.5% |
| map | 15/16 | 93.75% |
| mode | 16/16 | 100% |
| battleStart | 16/16 | 100% |
| credits | 16/16 | 100% |
| freeXp | 16/16 | 100% |
| damage | 14/16 | 87.5% |
| optional xp | 13/16 | 81.25% |

Both variants held the same four mandatory fields for review: player on `Screenshot_2024-11-14_133326.png`; player and map on `WTF.jpg`; damage on `image2.png`; and damage on `image5.png`. Both showed optional XP mismatches on `WTF.jpg`, `image1.png`, and `image6.png`. The comparator counted zero incorrectly accepted mandatory fields.

## Crop-boundary review

The OpenCV geometry audit found 77 proposals across 16 fixed images; 77/77 remained inside source bounds and 13/16 images had all five proposal types. However, 60/77 proposals (77.9%) touched a seed-window boundary, and only one proposal was marked isolated from adjacent UI. Geometry analysis itself averaged 53 ms/image. This is proposal coverage only, not evidence of correct field isolation. The next CV changes should focus on robust anchors, boundary-clipping detection, and explicit neighboring-field contamination checks.

## Decision

- Keep `OCR_CV_ASSIST=0` as the default.
- Do not claim accuracy improvement from the present OpenCV assist path.
- Retain zero-false-accept behavior and send unresolved player/map/damage values to human correction.
- Benchmark PaddleOCR separately, only when a complete offline bundle of pinned dependencies and model weights is available.
- Development data is not a holdout. Unattended production remains **NO-GO** until the target Windows acceptance, independent 50+ screenshot holdout, Discord staging, recovery and rollback gates pass.

Reproducibility artifacts in the recovery package include the paired JSON reports and OpenCV crop audit/contact sheet. The two raw run reports are on the same source fingerprint `2fb6d039f3c3cdc7dc725bc5827e4dc9cf3fe4d9ae6ac9ba6cdfe291d5baf22a`.
