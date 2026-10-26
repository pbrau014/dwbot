# Local CV and PaddleOCR adapter contract

This document is an implementation contract, not a claim that the adapter is already integrated. The authoritative application source must be imported and hashed before implementation.

## OpenCV crop proposal interface

Input:
- Immutable original screenshot path or in-memory buffer
- Known supported layout profile and original width/height
- Named field IDs and optional anchor templates

Output per proposal:
- Field ID
- Source image SHA-256
- Crop rectangle in original-image pixel coordinates (x, y, width, height)
- Anchor/template ID and match score, if used
- Preprocessing list and parameters
- Crop SHA-256 and local derived-artifact path
- Geometry validation: in-bounds, minimum dimensions, margins, overlap with neighboring fields, clipping risk
- Proposal decision: accepted for OCR / rejected for human review

OpenCV must not parse text, rank OCR values, use a roster to silently correct names, or set a field to accepted. Crop proposals with uncertain anchors or geometry outside validated tolerance are escalated to review.

## Local PaddleOCR worker boundary

PaddleOCR is a second local engine, not a replacement. The preferred first integration is a supervised child process with JSON Lines over stdin/stdout (not an HTTP service), subject to target-Windows packaging tests.

Required behavior:
- Disabled by default: PADDLEOCR_FIELD_FALLBACK=0
- Explicitly enabled only in benchmark runs
- Local-only model paths and pinned model hashes; no runtime downloads
- No API keys, network endpoint or telemetry
- Bounded input size, one request at a time initially, explicit timeout, graceful shutdown and hard termination on timeout
- Structured output includes raw text, boxes, confidence if available, engine/model/version and duration
- stderr is captured separately; stdout is reserved for protocol messages
- Process startup/model-load failure returns a typed unavailable result and does not crash the Tesseract path
- Kill/restart tests, malformed JSON tests, oversized image tests, missing model tests, offline test and network-attempt guard
- Model licensing, package footprint, CPU/RAM, cold-start and steady-state latency recorded

## Candidate policy

Tesseract.js remains primary. Paddle may be invoked only when a required field is missing, invalid, or ambiguous. Compare the actual field crops and preserve all candidates. Repeated PSM/crop variants of the same pixels are correlated evidence. Engine disagreement on a critical field must result in unresolved/review unless a field-specific rule has independently validated evidence. Never select a number solely because it is largest, appears most often, or has the highest generic OCR confidence.

## Benchmark matrix

Freeze the eligible fixture IDs and hashes first. For each eligible image run:
A. Current Tesseract.js pipeline.
B. OpenCV crop proposal + Tesseract.js.
C. Same proposed crops + selective local PaddleOCR.
D. Candidate selection + human-review gate.

Report raw OCR separately from end-to-end record accuracy. Include exact mandatory field counts by field, complete-record exactness, incorrect accepted mandatory values, unresolved/review rate, false rejection, optional XP accuracy, p50/p95 latency, CPU/RAM, model cold start, timeouts and network attempts. Do not use the independent holdout for tuning.

## Mandatory acceptance safety

A record is complete only if all eight required fields are validated: result, player, map, mode, battle start, credits, Free XP, and damage. XP is optional and reported separately. No incorrect mandatory value may be accepted. A missing or conflicting mandatory field blocks automatic acceptance and requires human correction.
