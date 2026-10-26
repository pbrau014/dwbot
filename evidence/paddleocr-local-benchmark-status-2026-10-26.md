# Local PaddleOCR integration and benchmark status

**Date:** 2026-10-26  
**Policy:** local inference only; no hosted OCR/vision APIs; no network model fetch during setup or inference.  
**Feature flag:** `PADDLEOCR_FIELD_FALLBACK=0` by default.  
**Runtime benchmark status:** **BLOCKED**, because no PaddlePaddle/PaddleOCR packages or PP-OCRv6 model weights are available in this environment.

## Model selection and configuration

The candidate pins CPU PaddlePaddle 3.3.1 and PaddleOCR 3.7.0 and requests local English `PP-OCRv6_medium_det` / `PP-OCRv6_medium_rec` model directories. PaddleOCR 3.7.0 (released 2026-06-11) documents PP-OCRv6 medium as the current general OCR default and supports English/Latin scripts. Links: [PaddleOCR 3.7.0 release notes](https://github.com/PaddlePaddle/PaddleOCR/releases), [official OCR pipeline/model docs](https://github.com/PaddlePaddle/PaddleOCR/blob/main/docs/version3.x/pipeline_usage/OCR.en.md), and [inference engine options](https://github.com/PaddlePaddle/PaddleOCR/blob/main/docs/version3.x/inference_deployment/local_inference/inference_engine.en.md).

The local worker was hardened to pass explicit detector/recognizer model names, explicit local model directories, `lang="en"`, CPU execution, no orientation/unwarping, and disabled MKL-DNN acceleration. It refuses a v3 constructor API that cannot accept explicit local model names/directories. Paddle candidates are still sent through the existing validators and consensus; a single Paddle read cannot authorize a required scoring value.

## Local-only safeguards

- PaddleOCR remains disabled unless explicitly enabled for a benchmark.
- Network sockets are blocked before importing Paddle/PaddleOCR; helper-reported blocked attempts fail closed.
- Model preparation now requires already-staged local files via `--skip-warm`; default invocation exits with a `BLOCKED` message without creating model paths or attempting a download.
- Legacy Windows/Linux installers that download packages/models now exit immediately with a local-only policy message.
- The offline Windows installer uses a hash-manifested local bundle and `pip --no-index`; it has no online fallback and keeps the feature disabled after smoke-test failure.
- The offline bundle packager includes already-present Windows-compatible wheels and both model directories only; it does not download, resolve, or fetch anything.

## Tests

- Paddle constructor model/version/CPU contract: passed.
- Synthetic offline bundle packaging + manifest verification: passed. (Synthetic wheels/weights validate the packager only; they are **not** usable model files and do not count as inference.)
- Default model-preparation network gate: passed; no download attempted.
- Legacy installer guard checks: passed.
- Existing Paddle field-fallback validation suite: 16/16 passed.
- `npm run benchmark:paddleocr:offline`: reports `BLOCKED` with `networkAttemptCount=0`, missing packages `paddle` and `paddleocr`, and no metrics. No Paddle OCR benchmark numbers are claimed.

## Next required action for real Paddle benchmarking

Provision an owner-approved, integrity-checked offline Windows wheelhouse containing PaddlePaddle 3.3.1, PaddleOCR 3.7.0 and all required Windows/Python-ABI-compatible dependencies, plus the two complete PP-OCRv6 medium model directories. Package with `scripts/package-paddleocr-offline-bundle.py`, transfer by approved means, and install using `scripts/install-paddleocr-offline-windows.ps1`. Then run socket-blocked smoke inference, raw OCR benchmarking, and integrated field-crop acceptance against the exact same frozen screenshots and ground truth as the Tesseract.js control. Keep `PADDLEOCR_FIELD_FALLBACK=0` unless the integrated benchmark improves exact mandatory records with zero incorrectly accepted mandatory fields and acceptable latency.

Windows clean-install/acceptance remains unverified in this Linux environment; Paddle's integrated benchmark remains blocked, not passed.
