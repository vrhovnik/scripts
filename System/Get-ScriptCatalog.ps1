<#
.SYNOPSIS
Builds a script catalog for this repository.

.DESCRIPTION
Scans the repository for script files and returns structured metadata used by documentation
and interactive script discovery tooling.

.PARAMETER RootPath
Repository root path to scan. Defaults to the parent of the System folder.

.PARAMETER IncludeTests
Includes files from tests folders when set.

.PARAMETER AsJson
Returns the catalog as JSON instead of objects.

.EXAMPLE
Get-ScriptCatalog.ps1

.EXAMPLE
Get-ScriptCatalog.ps1 -AsJson | Set-Content .\scripts.catalog.json
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$RootPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,

    [Parameter()]
    [switch]$IncludeTests,

    [Parameter()]
    [switch]$AsJson
)

function Get-ScriptSynopsis {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Extension
    )

    if ($Extension -eq ".ps1") {
        $content = Get-Content -LiteralPath $Path -Raw
        $match = [regex]::Match(
            $content,
            '(?is)<#.*?\.SYNOPSIS\s*(?<synopsis>.*?)\r?\n\s*(?:\.[A-Z]+|#>)'
        )

        if ($match.Success) {
            $firstSynopsisLine = ($match.Groups["synopsis"].Value -split '\r?\n' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) } | Select-Object -First 1).Trim()
            if ($firstSynopsisLine.Length -gt 180) {
                return $firstSynopsisLine.Substring(0, 180) + "..."
            }
            return $firstSynopsisLine
        }
    }

    $firstLine = Get-Content -LiteralPath $Path -TotalCount 1
    if ([string]::IsNullOrWhiteSpace($firstLine)) {
        return "No synopsis available."
    }

    return $firstLine.Trim().TrimStart('#', ':', ';', '*', '/').Trim()
}

$extensions = @("*.ps1", "*.bat", "*.cmd", "*.sh", "*.py", "*.js", "*.ts", "*.info")
$files = Get-ChildItem -Path $RootPath -Recurse -File -Include $extensions |
    Where-Object {
        $_.FullName -notmatch '\\\.git\\' -and
        ($IncludeTests -or $_.FullName -notmatch '\\tests\\')
    }

$catalog = foreach ($file in $files) {
    $relativePath = [System.IO.Path]::GetRelativePath($RootPath, $file.FullName)
    $normalizedPath = $relativePath -replace '\\', '/'
    $category = ($normalizedPath -split '/')[0]
    $extension = $file.Extension.ToLowerInvariant()

    [pscustomobject]@{
        Name         = $file.Name
        RelativePath = $normalizedPath
        FullPath     = $file.FullName
        Category     = $category
        Extension    = $extension
        IsRunnable   = $extension -in @(".ps1", ".bat", ".cmd", ".sh", ".py", ".js", ".ts")
        Synopsis     = Get-ScriptSynopsis -Path $file.FullName -Extension $extension
    }
}

$sortedCatalog = $catalog | Sort-Object Category, Name

if ($AsJson) {
    $sortedCatalog | ConvertTo-Json -Depth 5
}
else {
    $sortedCatalog
}
