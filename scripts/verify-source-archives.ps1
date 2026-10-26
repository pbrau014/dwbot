[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet('Base', 'Iteration21Overlay')]
    [string]$Kind,

    [Parameter(Mandatory = $true)]
    [string]$ArchivePath,

    [ValidateRange(1, 8589934592)]
    [long]$MaxExpandedBytes = 8589934592
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$expectedHashes = @{
    Base = 'b57942298f9d1405946f2eadf249ece94cf1cde05131172e44d0a4cd51099899'
    Iteration21Overlay = '35bdedfcfdeb3f861bb6b8e444732962644a053b7140c7494504a13e6c858d14'
}

$report = [ordered]@{
    schemaVersion = 1
    archiveName = [System.IO.Path]::GetFileName($ArchivePath)
    kind = $Kind
    archiveSha256 = $null
    expectedSha256 = $expectedHashes[$Kind]
    hashMatches = $false
    archiveIsSafe = $false
    expandedBytes = 0L
    entries = @()
    problems = @()
}

try {
    $resolvedArchive = (Resolve-Path -LiteralPath $ArchivePath -ErrorAction Stop).Path
    $report.archiveSha256 = (Get-FileHash -LiteralPath $resolvedArchive -Algorithm SHA256).Hash.ToLowerInvariant()
    $report.hashMatches = $report.archiveSha256 -eq $report.expectedSha256

    $zip = [System.IO.Compression.ZipFile]::OpenRead($resolvedArchive)
    try {
        $seenPaths = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
        $entryReports = [System.Collections.Generic.List[object]]::new()
        $unsafe = $false
        $expandedBytes = 0L

        foreach ($entry in $zip.Entries) {
            $normalizedPath = $entry.FullName.Replace('\', '/')
            $pathParts = $normalizedPath.Split('/')
            $isDirectory = $normalizedPath.EndsWith('/')
            $pathIsUnsafe = [string]::IsNullOrWhiteSpace($normalizedPath) -or
                $normalizedPath.StartsWith('/') -or
                [System.IO.Path]::IsPathRooted($normalizedPath) -or
                $normalizedPath.Contains(':') -or
                $normalizedPath.Contains([char]0)

            for ($partIndex = 0; $partIndex -lt $pathParts.Length; $partIndex++) {
                $part = $pathParts[$partIndex]
                $trailingDirectorySeparator = $isDirectory -and $partIndex -eq ($pathParts.Length - 1)
                if ($part -eq '.' -or $part -eq '..' -or ($part.Length -eq 0 -and -not $trailingDirectorySeparator)) {
                    $pathIsUnsafe = $true
                }
            }

            $unixType = ($entry.ExternalAttributes -shr 16) -band 0xF000
            $isSymbolicLink = $unixType -eq 0xA000
            $isReparsePoint = ($entry.ExternalAttributes -band 0x400) -ne 0
            $pathKey = $normalizedPath.TrimEnd('/')
            $duplicatePath = -not $seenPaths.Add($pathKey)
            if ($duplicatePath) { $pathIsUnsafe = $true }

            if ($pathIsUnsafe -or $isSymbolicLink -or $isReparsePoint) {
                $unsafe = $true
                $reasons = [System.Collections.Generic.List[string]]::new()
                if ($pathIsUnsafe) { $reasons.Add('unsafe_or_duplicate_path') }
                if ($isSymbolicLink) { $reasons.Add('symbolic_link') }
                if ($isReparsePoint) { $reasons.Add('reparse_point') }
            }
            else { $reasons = @() }

            $entryHash = $null
            if (-not $isDirectory) {
                $expandedBytes += [long]$entry.Length
                if ($expandedBytes -gt $MaxExpandedBytes) {
                    $unsafe = $true
                    $reasons = @($reasons) + 'expanded_size_limit_exceeded'
                }
                else {
                    $stream = $entry.Open()
                    try {
                        $sha = [System.Security.Cryptography.SHA256]::Create()
                        try { $entryHash = [System.Convert]::ToHexString($sha.ComputeHash($stream)).ToLowerInvariant() }
                        finally { $sha.Dispose() }
                    }
                    finally { $stream.Dispose() }
                }
            }

            $entryReports.Add([pscustomobject]@{
                path = $entry.FullName
                size = [long]$entry.Length
                sha256 = $entryHash
                safe = -not ($pathIsUnsafe -or $isSymbolicLink -or $isReparsePoint) -and $expandedBytes -le $MaxExpandedBytes
                problems = @($reasons)
            }) | Out-Null
        }

        $report.entries = @($entryReports)
        $report.expandedBytes = $expandedBytes
        $report.archiveIsSafe = -not $unsafe
    }
    finally { $zip.Dispose() }
}
catch {
    $report.problems = @($report.problems) + $_.Exception.Message
    $report.archiveIsSafe = $false
    $report | ConvertTo-Json -Depth 8 -Compress
    exit 3
}

if (-not $report.archiveIsSafe) {
    $report.problems = @($report.problems) + 'Archive contains unsafe paths or exceeds the expanded-size limit.'
}
elseif (-not $report.hashMatches) {
    $report.problems = @($report.problems) + 'Archive SHA-256 does not match the pinned authoritative archive hash.'
}

$report | ConvertTo-Json -Depth 8 -Compress
if (-not $report.archiveIsSafe) { exit 3 }
if (-not $report.hashMatches) { exit 2 }
exit 0

