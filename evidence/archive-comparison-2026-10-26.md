# Implementation archive comparison — 2026-10-26

## Inputs and measured hashes

| Source | File | Measured SHA-256 | ZIP entries |
|---|---|---|---:|
| GitHub `pbrau014/dwbot` `main` | `implementation.zip` | `088b16a4f36acb80dd576ccb1dda440ba14410f10101041bbd597a3a518ee4af` | 9 |
| Connected Dropbox | `/implementationNew.zip` | `0644d2ea41be1f53e2636891bd6706b4608a4fd627c772cb41a3199fc24a6f0b` | 8 |

The Dropbox archive was downloaded using its connected account file ID `id:4LyMe5dno94AAAAAAAAABg`. GitHub's archive was read from the `main` branch. Both archives were enumerated locally; SHA-256 was calculated for each archive and each ZIP member.

## Comparison

All eight entries in Dropbox `implementationNew.zip` have the same path, uncompressed size, and member SHA-256 in GitHub `implementation.zip`:

| Shared entries | Result |
|---|---|
| `1.txt`–`6.txt` | All six match byte-for-byte |
| `score_report_imgToDiscord.html` | Matches byte-for-byte |
| `yolo_tournament_scoreCalculator.html` | Matches byte-for-byte |

GitHub `implementation.zip` contains one additional entry: `0.txt`. Dropbox `implementationNew.zip` does not contain it. This difference does not change the agreed execution order of `1.txt` through `6.txt`.

## What the archives establish

The two ZIPs are equivalent for the six requested plans and the two HTML assets. Their differing archive-level hashes are explained by GitHub's extra `0.txt` (and archive metadata). The ZIP member listing does not establish that either HTML page is integrated with a working bot.

Neither ZIP is the authoritative V4 application source (`YoloDiscordBotV4.zip`) or complete Iteration 21 patch (`DWBOT_ITERATION21_PATCH.zip`). Connected Dropbox searches for `YoloDiscordBotV4`, `DWBOT_ITERATION21_PATCH`, and `YoloDiscordBot V4 source` returned no results. GitHub code searches for both archive names returned no results; the handoff branch tree contains project status, plans, evidence, patch notes, and validation scripts, not an application source tree. The authoritative archive requirements remain blocked pending delivery of files whose SHA-256 matches the pinned values in the project evidence.

## Reproducible local checks

The read-only `scripts/verify-source-archives.ps1` tool inventories candidate ZIP members, calculates the archive and member SHA-256 values, and rejects unsafe paths without extracting. On these two plan bundles it returned exit code `2` (expected source hash mismatch), reported `archiveIsSafe: true`, and listed 9 and 8 entries respectively.

