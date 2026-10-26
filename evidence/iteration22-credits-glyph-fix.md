# Iteration 22 — Credits trailing-currency glyph recovery

**Candidate revision:** uploaded source tree + verified Iteration 21 overlay + previously reviewed O/0 identity consensus fix.
**Runtime:** Node.js v24.22.1 x64 / npm 11.19.1 / Linux.
**Release posture:** NO-GO pending Windows clean install, final acceptance, independent holdout, and staging/recovery.

## Failure reproduced

On `fixtures/four-screenshots/schlieffen-defeat.jpg`, the localized reward-row OCR produced a single token `317943®`. Two broad reads (source IDs 6 and 7) independently supported Credits `317943`, while the only stable geometry crop quorum interpreted the trailing currency symbol as a zero and yielded `3179430`. Previous logic correctly refused to silently accept the overlong value but left the mandatory Credits field unresolved.

## Guarded fix

The new helper `selectAnchoredCreditAfterTrailingAdornment` accepts the complete localized digit anchor only when all of these hold: a single localized row token has a valid 5–9 digit prefix plus a trailing nonnumeric glyph; the digits have independent broad-source support and no independent conflict; there is exactly one stable crop group; the crop group equals anchor-plus-one-zero and has at least six reads spanning three geometries and two PSMs; and the longer value has no independent support. All other conditions return unresolved. No blanket stripping/replacement is done.

Patch: `patches/ITERATION22-CREDITS-GLYPH-FIX.patch`, SHA-256 `d67db3621a0163e2dcee8062c47f36ecf7d2bd709d6479ca0a318c2111f91743`.
A combined O/Q + Credits patch is also in the local sanitized candidate for convenience, but should not be applied in addition to both separate patches.

## Evidence

- Unit suite after implementation: **183 passed, 0 failed, 0 skipped** using existing bundled dependencies.
- Numeric parser tests: **12 passed, 0 failed**; negative tests prove fail-closed behavior for weak support, competing stable groups, insufficient reads, multi-word anchors, missing glyph, and independent conflict.
- Actual Schlieffen image: **1/1 mandatory record complete**, all eight mandatory fields exact; Credits `317943` recovered; XP remained unresolved and therefore does not block completeness. The all-fields comparison is reported separately and is not exact because XP is optional but missed.
- Test ran on Node v24.22.1 with `PADDLEOCR_FIELD_FALLBACK=0`, `OCR_CV_ASSIST=0`, and network blocking enabled; no blocked network attempts were recorded.

This is a targeted regression fix on a development screenshot, not an independent holdout. Full final-candidate acceptance, Windows clean install, unseen-image holdout, and Discord/recovery/rollback gates remain open.
