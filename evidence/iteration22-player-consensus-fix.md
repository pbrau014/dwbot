# Iteration 22: player-name OCR confusable consensus

**Status:** implemented in the isolated candidate; patch is in this PR for review.
**Runtime tested:** Node.js v24.22.1 x64, npm 11.19.1, Linux.
**Release status:** NO-GO pending the complete acceptance report and all independent release gates.

## Failure reproduced

On `fixtures/four-screenshots/asashio-defeat.jpg`, multiple Tesseract.js candidate reads included the incorrect player spelling `[OVF]O0ldschoolGaming_YouTube`; the approved ground truth and the screenshot itself read `[OVF]OldschoolGaming_YouTube`. The rest of the required fields were exact. The previous consensus gate handled same-length glyph confusions but not a single inserted character, and repeated PSM/crop reads from the same labelled source family could be overcounted.

## Change

The candidate narrows correction to the player-name confusable consensus path. It permits exactly one inserted/deleted ambiguous glyph only when removal yields the competing spelling or a same-length confusable variant. In that path only, source-family weights are capped at the strongest single read per labelled family, so correlated PSM/crop variants cannot dominate independent evidence. A tie still returns `Not detected` and keeps the mandatory field pending human correction. No unconditional character replacement was added.

The unified patch is preserved at `patches/ITERATION22-PLAYER-CONFUSABLE-CONSENSUS-FIX.patch` (SHA-256 `a34b5572e4c36bd11bb745016f5841e7ed77382bc5f0c9ea755f808066e5a14d`). It passed `git apply --check` against the isolated Iteration 21 candidate.

## Verification completed so far

- Full Node 24 unit suite after the change: **180 passed, 0 failed, 0 skipped**.
- Targeted battle-record tests: **27 passed, 0 failed**.
- Real Asashio screenshot after the change: **1/1 exact mandatory record**; all eight mandatory fields and optional XP matched; player spelling exact; local/offline network guard enabled; no blocked network attempts were logged.
- The complete `npm run test:tesseractjs` sequence is currently being run on Node.js v24.22.1 with `PADDLEOCR_FIELD_FALLBACK=0` and `OCR_CV_ASSIST=0`, using the bundle's existing dependencies rather than a clean npm install. Its final report is not yet available.
- Clean `npm ci` remains blocked because the environment cannot resolve `registry.npmjs.org` (`EAI_AGAIN`). The package-lock was not altered to work around that network limitation.

## Safety and release gates

This result covers one previously failing image, not the independent holdout. It does not prove Windows acceptance, 50+ unseen-image holdout accuracy, live Discord behavior, SQLite/JSON recovery, backup restore, or rollback. Keep unattended production **NO-GO** until those gates are completed with reproducible evidence.
