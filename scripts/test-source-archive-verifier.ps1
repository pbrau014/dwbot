[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$toolPath = Join-Path $PSScriptRoot 'verify-source-archives.ps1'
$testRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('dwbot-archive-verifier-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $testRoot | Out-Null

function New-TestArchive([string]$Path, [string]$EntryName) {
    $archive = [System.IO.Compression.ZipFile]::Open($Path, [System.IO.Compression.ZipArchiveMode]::Create)
    try {
        $entry = $archive.CreateEntry($EntryName)
        $stream = $entry.Open()
        try {
            $bytes = [System.Text.Encoding]::UTF8.GetBytes('archive verifier fixture')
            $stream.Write($bytes, 0, $bytes.Length)
        }
        finally { $stream.Dispose() }
    }
    finally { $archive.Dispose() }
}

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $safeArchive = Join-Path $testRoot 'safe.zip'
    New-TestArchive $safeArchive 'docs/readme.txt'
    $safeOutput = (& $toolPath -Kind Base -ArchivePath $safeArchive 2>&1 | Out-String)
    $safeExit = $LASTEXITCODE
    if ($safeExit -ne 2) { throw "Expected safe unknown archive to be rejected only for SHA mismatch (exit 2); received $safeExit`n$safeOutput" }
    $safeReport = $safeOutput | ConvertFrom-Json
    if (-not $safeReport.archiveIsSafe -or $safeReport.entries.Count -ne 1) { throw 'Safe archive inventory was not reported correctly.' }
    if ($safeReport.entries[0].path -ne 'docs/readme.txt') { throw 'Safe archive member path was not preserved.' }

    $unsafeArchive = Join-Path $testRoot 'unsafe.zip'
    New-TestArchive $unsafeArchive '../outside.txt'
    $unsafeOutput = (& $toolPath -Kind Base -ArchivePath $unsafeArchive 2>&1 | Out-String)
    $unsafeExit = $LASTEXITCODE
    if ($unsafeExit -ne 3) { throw "Expected traversal member to be rejected as unsafe (exit 3); received $unsafeExit`n$unsafeOutput" }
    $unsafeReport = $unsafeOutput | ConvertFrom-Json
    if ($unsafeReport.archiveIsSafe) { throw 'Traversal archive was marked safe.' }

    Write-Output 'PASS: safe archive inventory is read-only and reports the expected-hash mismatch.'
    Write-Output 'PASS: parent-traversal archive member is rejected.'
}
finally {
    if (Test-Path -LiteralPath $testRoot) { Remove-Item -LiteralPath $testRoot -Recurse -Force }
}

