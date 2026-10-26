# Iteration 22 — fail-closed player identity consensus

## Why this patch was required

The 16-image development-corpus run found an unsafe result for `image5.png`: the player field was accepted as `[HO-FL]VeritechCEQ`, while the reviewed value is `[HO-FL]VeritechCEO`. The same record had unresolved Damage. The earlier O/Q confusable rule was present, but the parser missed identity strings where OCR dropped the opening square bracket (for example `HO-FL]VeritechCEO »» X THUNDERER`). As a result, only the full-screen Q spelling reached the candidate group, and the generic majority-count fallback overrode the special-path uncertainty.

## Change

1. Parse a clipped opening clan-tag bracket only when the same line has a closing bracket, nonempty player token, and explicit ship separator/tier marker.
2. Treat each source family as one vote. If the same source family supports multiple competing spellings, it contributes no vote to any of them rather than being counted for each.
3. If the confusable-only independent-source rule cannot pick a sufficiently supported unique spelling, return unresolved and explicitly stop the generic majority fallback from re-accepting it.
4. Add a regression reproducing the conflicting CEO/CEQ reads and asserting that the player remains unresolved when only one weak source family supports the chosen variant.

Patch: `patches/ITERATION22-IDENTITY-FAIL-CLOSED-FIX.patch` (local validation SHA-256: `b617f38781093b322f70b8572266b741c37b39db6468843a8c6dbe782c210ec8`).

## Verification

- `node --test tests/battle-record.test.js`: 30 passed, 0 failed.
- Full `npm test` after this patch: 185 passed, 0 failed, 0 skipped (Node.js v24.22.1 x64, existing prebundled dependencies).
- Targeted Asashio image: 1/1 exact.
- Targeted Screenshot_16: 1/1 exact.
- Targeted `image5.png`: field is now held as unresolved, not accepted as `VeritechCEQ`; the record remains incomplete because Damage is also unresolved. This is the intended no-false-accept behavior.
- The final corrected 16-image sequential run with a network-blocking guard is in progress. Do not use earlier pre-fix reports to claim this patch passed the full corpus.

This fixes the observed false-accept path; it does not complete the independent holdout. The development corpus is for regression, not independent validation. Production stays NO-GO pending final corpus review, clean install, target Windows validation, 50+ unseen screenshots with zero false accepts/network attempts, live staging, restore, and rollback.
