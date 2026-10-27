[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SourceArchive,

    [Parameter(Mandatory = $true)]
    [string]$PatchArchive,

    [string]$OutputRoot = (Join-Path (Get-Location).Path ("DWBOT_ACCEPTANCE_{0}" -f (Get-Date -Format 'yyyyMMdd_HHmmss')))
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedBaseSha256 = 'b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899'
$ExpectedPatchSha256 = '35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14'
$ExpectedNodeVersion = 'v24.22.1'
$RequiredRunnerPhrase = 'all eight mandatory fields'

function Get-Sha256([string]$Path) {
    return (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function Get-ChildPath([string]$Root, [string]$RelativePath) {
    $fullRoot = [System.IO.Path]::GetFullPath($Root)
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $fullRoot $RelativePath))
    $prefix = $fullRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $fullPath.StartsWith($prefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Unsafe path in patch manifest: $RelativePath"
    }
    return $fullPath
}

function Invoke-NpmLogged {
    param(
        [Parameter(Mandatory = $true)][string]$StepName,
        [Parameter(Mandatory = $true)][string[]]$NpmArguments,
        [Parameter(Mandatory = $true)][string]$ProjectDirectory,
        [Parameter(Mandatory = $true)][string]$LogDirectory,
        [Parameter(Mandatory = $true)][System.Collections.Generic.List[object]]$RunResults
    )

    $logPath = Join-Path $LogDirectory ("{0}.log" -f $StepName)
    "STEP: npm $($NpmArguments -join ' ')" | Set-Content -LiteralPath $logPath -Encoding UTF8
    $start = Get-Date
    Push-Location $ProjectDirectory
    try {
        & npm.cmd @NpmArguments 2>&1 | Tee-Object -LiteralPath $logPath -Append
        $exitCode = $LASTEXITCODE
    }
    finally {
        Pop-Location
    }
    $end = Get-Date
    $RunResults.Add([pscustomobject]@{
        step = $StepName
        command = ('npm ' + ($NpmArguments -join ' '))
        startedAt = $start.ToString('o')
        finishedAt = $end.ToString('o')
        durationSeconds = [Math]::Round(($end - $start).TotalSeconds, 2)
        exitCode = $exitCode
        logFile = [System.IO.Path]::GetFileName($logPath)
    }) | Out-Null
    return $exitCode
}

$runStarted = Get-Date
$resolvedSource = (Resolve-Path -LiteralPath $SourceArchive).Path
$resolvedPatch = (Resolve-Path -LiteralPath $PatchArchive).Path
$resolvedOutput = [System.IO.Path]::GetFullPath($OutputRoot)
if (Test-Path -LiteralPath $resolvedOutput) {
    throw "OutputRoot already exists; choose a new path so evidence cannot be overwritten: $resolvedOutput"
}
New-Item -ItemType Directory -Path $resolvedOutput | Out-Null
$baseExtract = Join-Path $resolvedOutput 'base-extracted'
$patchExtract = Join-Path $resolvedOutput 'patch-extracted'
$runArtifacts = Join-Path $resolvedOutput 'run-artifacts'
New-Item -ItemType Directory -Path $runArtifacts | Out-Null

$runResults = [System.Collections.Generic.List[object]]::new()
$sourceHash = Get-Sha256 $resolvedSource
$patchHash = Get-Sha256 $resolvedPatch
if ($sourceHash -ne $ExpectedBaseSha256) {
    throw "Base archive SHA-256 mismatch. Expected $ExpectedBaseSha256; found $sourceHash. Nothing was patched."
}
if ($patchHash -ne $ExpectedPatchSha256) {
    throw "Iteration 21 patch ZIP SHA-256 mismatch. Expected $ExpectedPatchSha256; found $patchHash. Nothing was patched."
}

$nodeVersion = (& node --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'Node.js is not available on PATH.' }
if ($nodeVersion -ne $ExpectedNodeVersion) {
    throw "Expected Node.js $ExpectedNodeVersion on target Windows; found $nodeVersion. Install/pin the target runtime before acceptance."
}
$npmVersion = (& npm.cmd --version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'npm.cmd is not available on PATH.' }
$nodeArch = (& node -p "process.arch" 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0 -or $nodeArch -ne 'x64') { throw "Expected Node.js x64; found architecture '$nodeArch'." }
if (-not (Get-Command magick -ErrorAction SilentlyContinue)) {
    throw 'ImageMagick command `magick` was not found on PATH. Install/verify it before acceptance.'
}
$magickVersion = (& magick -version 2>&1 | Out-String).Trim()
if ($LASTEXITCODE -ne 0) { throw 'ImageMagick is present but `magick -version` failed.' }

Expand-Archive -LiteralPath $resolvedSource -DestinationPath $baseExtract
Expand-Archive -LiteralPath $resolvedPatch -DestinationPath $patchExtract

$projectCandidates = @(Get-ChildItem -LiteralPath $baseExtract -Recurse -File -Filter 'package.json' | Where-Object {
    Test-Path -LiteralPath (Join-Path $_.Directory.FullName 'scripts\run-additional-screenshot-regression.js')
})
if ($projectCandidates.Count -ne 1) {
    throw "Expected exactly one V4 project package.json matching scripts\run-additional-screenshot-regression.js; found $($projectCandidates.Count). Inspect the archive structure manually."
}
$projectDir = $projectCandidates[0].Directory.FullName

$manifestPath = Join-Path $patchExtract 'SHA256SUMS-ITERATION21.txt'
if (-not (Test-Path -LiteralPath $manifestPath)) { throw 'Patch SHA256SUMS-ITERATION21.txt is missing.' }
$manifestEntries = @()
foreach ($line in Get-Content -LiteralPath $manifestPath) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    if ($line -notmatch '^([0-9a-fA-F]{64})\s{2}(.+)$') { throw "Invalid patch manifest line: $line" }
    $manifestEntries += [pscustomobject]@{ sha256 = $Matches[1].ToLowerInvariant(); path = $Matches[2].Trim() }
}
if ($manifestEntries.Count -ne 21) { throw "Expected 21 patch manifest entries; found $($manifestEntries.Count)." }

# Verify each patch payload hash before copying, then apply only paths named in the manifest.
foreach ($entry in $manifestEntries) {
    $overlayFile = Get-ChildPath $patchExtract $entry.path
    if (-not (Test-Path -LiteralPath $overlayFile -PathType Leaf)) { throw "Patch payload missing: $($entry.path)" }
    $actual = Get-Sha256 $overlayFile
    if ($actual -ne $entry.sha256) { throw "Patch payload hash mismatch: $($entry.path)" }
    $targetFile = Get-ChildPath $projectDir $entry.path
    $targetParent = Split-Path -Parent $targetFile
    if (-not (Test-Path -LiteralPath $targetParent)) { New-Item -ItemType Directory -Path $targetParent -Force | Out-Null }
    Copy-Item -LiteralPath $overlayFile -Destination $targetFile -Force
}

# Re-verify the actual patched tree against the same 21-entry manifest.
foreach ($entry in $manifestEntries) {
    $targetFile = Get-ChildPath $projectDir $entry.path
    if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) { throw "Patched file missing: $($entry.path)" }
    if ((Get-Sha256 $targetFile) -ne $entry.sha256) { throw "Patched tree hash mismatch: $($entry.path)" }
}

$runnerPath = Join-Path $projectDir 'scripts\run-additional-screenshot-regression.js'
$runnerText = Get-Content -LiteralPath $runnerPath -Raw
if ($runnerText -notmatch [regex]::Escape($RequiredRunnerPhrase)) {
    throw "Patch-contract check failed: runner does not contain '$RequiredRunnerPhrase'."
}
$xpRegression = @(Get-ChildItem -LiteralPath (Join-Path $projectDir 'tests') -Recurse -File -Filter '*.test.js' | Select-String -Pattern 'optional XP' -SimpleMatch)
if ($xpRegression.Count -lt 1) { throw 'No optional-XP regression test was found under tests\.' }

# Remove a potentially secret local .env only from the isolated extracted test copy.
# The original archive and source file are never changed.
$envPath = Join-Path $projectDir '.env'
$removedEnv = $false
if (Test-Path -LiteralPath $envPath -PathType Leaf) {
    Remove-Item -LiteralPath $envPath -Force
    $removedEnv = $true
}

$oldEnv = @{}
$testEnvironment = @{
    OCR_ENGINE = 'tesseractjs'
    PADDLEOCR_FIELD_FALLBACK = '0'
    OCR_CV_ASSIST = '0'
}
foreach ($name in $testEnvironment.Keys) {
    $oldEnv[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
    [Environment]::SetEnvironmentVariable($name, $testEnvironment[$name], 'Process')
}

$overallExitCode = 0
try {
    $ciExit = Invoke-NpmLogged -StepName 'npm-ci' -NpmArguments @('ci') -ProjectDirectory $projectDir -LogDirectory $runArtifacts -RunResults $runResults
    if ($ciExit -ne 0) {
        $overallExitCode = $ciExit
    }
    else {
        $testExit = Invoke-NpmLogged -StepName 'npm-test' -NpmArguments @('test') -ProjectDirectory $projectDir -LogDirectory $runArtifacts -RunResults $runResults
        if ($testExit -ne 0) {
            $overallExitCode = $testExit
        }
        else {
            $ocrEvidenceWindowStart = (Get-Date).ToUniversalTime().AddSeconds(-2)
            $ocrExit = Invoke-NpmLogged -StepName 'npm-test-tesseractjs' -NpmArguments @('run', 'test:tesseractjs') -ProjectDirectory $projectDir -LogDirectory $runArtifacts -RunResults $runResults
            if ($ocrExit -ne 0) { $overallExitCode = $ocrExit }

            # Copy every newly-written acceptance-report folder (including per-stage logs)
            # to the evidence root, then hash it together with the console logs.
            $ocrReportsRoot = Join-Path $projectDir 'testdata\ocr-acceptance'
            $freshReports = @()
            if (Test-Path -LiteralPath $ocrReportsRoot) {
                $freshReports = @(Get-ChildItem -LiteralPath $ocrReportsRoot -Recurse -File -Filter 'acceptance-report.json' | Where-Object {
                    $_.LastWriteTimeUtc -ge $ocrEvidenceWindowStart
                })
            }
            if ($freshReports.Count -eq 0) {
                $overallExitCode = 1
                Write-Warning 'No newly-written acceptance-report.json was found. The OCR run is not considered evidenced; inspect the console log and script output.'
            }
            else {
                $evidenceOcrRoot = Join-Path $runArtifacts 'ocr-reports'
                New-Item -ItemType Directory -Path $evidenceOcrRoot -Force | Out-Null
                foreach ($reportFile in $freshReports) {
                    $reportDirectory = $reportFile.Directory.FullName
                    $relativeDirectory = $reportDirectory.Substring($ocrReportsRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar).Length).TrimStart([System.IO.Path]::DirectorySeparatorChar)
                    $targetDirectory = if ($relativeDirectory -eq '.') { $evidenceOcrRoot } else { Join-Path $evidenceOcrRoot $relativeDirectory }
                    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
                    Copy-Item -Path (Join-Path $reportDirectory '*') -Destination $targetDirectory -Recurse -Force
                }
            }
        }
    }
}
finally {
    foreach ($name in $testEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($name, $oldEnv[$name], 'Process')
    }
}

$meta = [pscustomobject]@{
    startedAt = $runStarted.ToString('o')
    finishedAt = (Get-Date).ToString('o')
    computerName = $env:COMPUTERNAME
    operatingSystem = (Get-CimInstance Win32_OperatingSystem).Caption
    operatingSystemVersion = [System.Environment]::OSVersion.VersionString
    processArchitecture = $env:PROCESSOR_ARCHITECTURE
    nodeVersion = $nodeVersion
    npmVersion = $npmVersion
    nodeArch = $nodeArch
    magickVersionFirstLine = ($magickVersion -split "`r?`n")[0]
    sourceArchiveName = [System.IO.Path]::GetFileName($resolvedSource)
    sourceArchiveSha256 = $sourceHash
    patchArchiveName = [System.IO.Path]::GetFileName($resolvedPatch)
    patchArchiveSha256 = $patchHash
    patchedFilesVerified = $manifestEntries.Count
    runnerContractVerified = $true
    optionalXpRegressionFound = $true
    removedRootEnvFromIsolatedCopy = $removedEnv
    effectiveNonsecretConfig = $testEnvironment
    commands = @($runResults)
    commandSequenceExitCode = $overallExitCode
    releaseDecision = 'NO-GO until independent holdout, Discord staging, and restore gates pass'
} 
$metaPath = Join-Path $runArtifacts 'acceptance-run-meta.json'
$meta | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $metaPath -Encoding UTF8

# Hash the run artifacts, including this metadata file. The manifest itself is deliberately excluded.
$hashManifestPath = Join-Path $runArtifacts 'SHA256SUMS-ACCEPTANCE.txt'
$hashLines = @(Get-ChildItem -LiteralPath $runArtifacts -Recurse -File | Where-Object { $_.FullName -ne $hashManifestPath } | Sort-Object FullName | ForEach-Object {
    $relative = $_.FullName.Substring($runArtifacts.TrimEnd([System.IO.Path]::DirectorySeparatorChar).Length).TrimStart([System.IO.Path]::DirectorySeparatorChar).Replace('\', '/')
    "$(Get-Sha256 $_.FullName)  $relative"
})
$hashLines | Set-Content -LiteralPath $hashManifestPath -Encoding UTF8

Write-Host "Evidence root: $resolvedOutput"
Write-Host "Acceptance artifacts: $runArtifacts"
Write-Host "Node: $nodeVersion; npm: $npmVersion; arch: $nodeArch"
Write-Host 'PADDLEOCR_FIELD_FALLBACK=0; OCR_ENGINE=tesseractjs; OCR_CV_ASSIST=0'
if ($overallExitCode -ne 0) {
    Write-Error "One or more acceptance commands failed (last nonzero exit code: $overallExitCode). Production remains NO-GO."
    exit 1
}
Write-Warning 'The scripted install/tests completed successfully. This is not production approval; the independent OCR holdout, Discord staging, and restore rehearsal remain required.'