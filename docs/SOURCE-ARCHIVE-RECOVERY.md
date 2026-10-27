# Source archive recovery and verification

The repository does not contain the authoritative DWBOT application source or the complete Iteration 21 patch archive. Do not reconstruct application code from the implementation plan ZIPs.

## Verified archive comparison (2026-10-26)

The GitHub `main` archive `implementation.zip` and Dropbox `/implementationNew.zip` are plan/interface bundles, not the V4 application source or the Iteration 21 overlay. Their exact contents and measured SHA-256 values are recorded in [archive-comparison-2026-10-26.md](../evidence/archive-comparison-2026-10-26.md).

The following authoritative archive hashes are recorded in repository evidence and the acceptance runner:

| Archive | Required SHA-256 |
|---|---|
| `YoloDiscordBotV4.zip` | `b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899` |
| `DWBOT_ITERATION21_PATCH.zip` | `35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14` |

These are target hashes, not hashes measured from available copies. Dropbox and GitHub searches for the two archive names returned no results in this review. The source and overlay remain blocked until accessible archive bytes match the expected hashes.

## Verify newly supplied files

Run the read-only inventory tool before extracting either archive:

```powershell
pwsh -NoProfile -File scripts/verify-source-archives.ps1 `
  -Kind Base `
  -ArchivePath .\YoloDiscordBotV4.zip > .\source-archive-base-verification.json
$LASTEXITCODE

pwsh -NoProfile -File scripts/verify-source-archives.ps1 `
  -Kind Iteration21Overlay `
  -ArchivePath .\DWBOT_ITERATION21_PATCH.zip > .\source-archive-overlay-verification.json
$LASTEXITCODE
```

Exit code `0` means the ZIP hash matches the pinned archive and all members pass the safe-path and expanded-size checks. Exit code `2` means the ZIP is readable but its hash does not match; do not treat it as authoritative. Exit code `3` means the archive is unreadable or contains an unsafe/duplicate path, a link/reparse entry, or exceeds the expanded-size limit. The JSON output records the archive hash, expected hash, safety status, and SHA-256 for each readable file member.

The tool does not extract, patch, modify, or delete files. After a matching base and overlay are supplied, follow `scripts/windows-iteration21-acceptance.ps1` and the release runbook. Preserve the originals, extract into a new empty directory, apply only manifest-listed overlay files, and confirm all 21 manifest hashes before running project code.

