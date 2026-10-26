# Iteration 22: O/Q player-name consensus validation

**Runtime:** Node.js v24.22.1, npm 11.19.1, Linux x64.
**Change scope:** adds the specific O/Q glyph-confusion pair to the existing player-name consensus safety path and covers it with a test; it does not rewrite arbitrary OCR strings.
**Image:** `fixtures/additional-screenshots/Screenshot_16.jpg`
**Image SHA-256:** `4a58aad7cb1d21f9bb457e1ad728fee59ebff3873a1e47938cf401d41f784bbc`

## Finding

The image visibly shows player name `[HO-FL]VeritechCEO`, while the prior baseline accepted `[HO-FL]VeritechCEQ`. The added O/Q relation allows the existing consensus decision to use the stronger prepared-identity family rather than the higher raw confidence of a correlated rescue read. The logic retains fail-closed behavior if the competing spellings do not have unique support.

## Verification

- Unit suite after this proposal: **181 passed, 0 failed, 0 skipped**.
- Targeted real-image run: **1/1 record exact**, all eight mandatory fields and optional XP exact; elapsed 78.7 seconds.
- Runtime metadata in the report: Node.js v24.22.1, x64, Tesseract.js 6.0.1 / core 6.1.2, local `eng.traineddata`.
- `networkBlocked=true`; the network guard was preloaded into child processes and no blocked-attempt log was created (zero observed blocked attempts).
- Two-step patch-application check passed against the isolated Iteration 21 source copy: first the O/0 insertion/player-consensus fix, then this O/Q change.

This is a targeted regression result, not an independent holdout or a complete 16-image acceptance pass. Do not interpret it as production approval. The full sequential Node 24 OCR acceptance is still in progress on the preceding candidate without the O/Q proposal to preserve test provenance. Clean `npm ci`, Windows x64 acceptance, 50+ unseen-image holdout, Discord staging, backup restore, and rollback remain outstanding gates.
