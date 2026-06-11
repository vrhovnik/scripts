<#
.SYNOPSIS
Interactive script launcher with search, docs preview, and execution.

.DESCRIPTION
Loads a catalog of scripts from this repository, lets you filter by search text,
preview script documentation, and execute a selected script.

.PARAMETER RootPath
Repository root path. Defaults to the parent of the System folder.

.PARAMETER Search
Optional initial search filter.

.PARAMETER MaxResults
Maximum number of matching items to display per query.

.PARAMETER PreviewOnly
Shows documentation preview only and disables execution prompts.

.EXAMPLE
Invoke-ScriptLauncher.ps1

.EXAMPLE
Invoke-ScriptLauncher.ps1 -Search "Azure" -MaxResults 25
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$RootPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,

    [Parameter()]
    [string]$Search = "",

    [Parameter()]
    [ValidateRange(5, 200)]
    [int]$MaxResults = 30,

    [Parameter()]
    [switch]$PreviewOnly
)

function Get-HelpPreview {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,

        [Parameter(Mandatory)]
        [string]$Extension
    )

    if ($Extension -ne ".ps1") {
        return "No PowerShell comment-based help available for this file type."
    }

    $content = Get-Content -LiteralPath $Path -Raw
    $descriptionMatch = [regex]::Match(
        $content,
        '(?is)\.DESCRIPTION\s*(?<text>.*?)\r?\n\s*(?:\.[A-Z]+|#>)'
    )
    $exampleMatch = [regex]::Match(
        $content,
        '(?is)\.EXAMPLE\s*(?<text>.*?)\r?\n\s*(?:\.[A-Z]+|#>)'
    )

    $preview = @()
    if ($descriptionMatch.Success) {
        $preview += "Description: " + (($descriptionMatch.Groups["text"].Value -replace '\r?\n', ' ').Trim())
    }
    if ($exampleMatch.Success) {
        $preview += "Example: " + (($exampleMatch.Groups["text"].Value -replace '\r?\n', ' ').Trim())
    }

    if ($preview.Count -eq 0) {
        return "No .DESCRIPTION/.EXAMPLE help sections found."
    }

    return ($preview -join [Environment]::NewLine)
}

function Invoke-SelectedScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [pscustomobject]$Item
    )

    if (-not $Item.IsRunnable) {
        Write-Warning "The selected file type is not runnable from this launcher."
        return
    }

    $confirm = Read-Host "Run '$($Item.Name)' now? (y/n)"
    if ($confirm -notin @("y", "Y", "yes", "YES")) {
        return
    }

    switch ($Item.Extension) {
        ".ps1" { & $Item.FullPath; break }
        ".bat" { & cmd.exe /c "`"$($Item.FullPath)`""; break }
        ".cmd" { & cmd.exe /c "`"$($Item.FullPath)`""; break }
        default { & $Item.FullPath; break }
    }
}

$catalogScriptPath = Join-Path $PSScriptRoot "Get-ScriptCatalog.ps1"
if (-not (Test-Path -LiteralPath $catalogScriptPath)) {
    throw "Required script not found: $catalogScriptPath"
}

$catalog = & $catalogScriptPath -RootPath $RootPath
if (-not $catalog) {
    throw "No scripts found under '$RootPath'."
}

$currentFilter = $Search
while ($true) {
    $filtered = $catalog
    if (-not [string]::IsNullOrWhiteSpace($currentFilter)) {
        $filtered = $catalog | Where-Object {
            $_.Name -like "*$currentFilter*" -or
            $_.RelativePath -like "*$currentFilter*" -or
            $_.Synopsis -like "*$currentFilter*"
        }
    }

    $filtered = $filtered | Select-Object -First $MaxResults

    Write-Host ""
    Write-Host "=== Script Launcher ===" -ForegroundColor Cyan
    Write-Host "Filter: '$currentFilter' (empty = all, q = quit)"
    Write-Host ""

    if (-not $filtered) {
        Write-Warning "No scripts matched this filter."
        $nextFilter = Read-Host "Enter new filter"
        if ($nextFilter -eq "q") { break }
        $currentFilter = $nextFilter
        continue
    }

    for ($i = 0; $i -lt $filtered.Count; $i++) {
        $item = $filtered[$i]
        Write-Host ("[{0}] {1}  |  {2}  |  {3}" -f ($i + 1), $item.Name, $item.Category, $item.Synopsis)
    }

    $selection = Read-Host "Select #, type /newfilter, or q"
    if ($selection -eq "q") { break }
    if ($selection.StartsWith("/")) {
        $currentFilter = $selection.TrimStart("/")
        continue
    }

    $index = 0
    if (-not [int]::TryParse($selection, [ref]$index) -or $index -lt 1 -or $index -gt $filtered.Count) {
        Write-Warning "Invalid selection."
        continue
    }

    $selected = $filtered[$index - 1]
    $preview = Get-HelpPreview -Path $selected.FullPath -Extension $selected.Extension

    Write-Host ""
    Write-Host ("Name:       {0}" -f $selected.Name) -ForegroundColor Green
    Write-Host ("Path:       {0}" -f $selected.RelativePath)
    Write-Host ("Category:   {0}" -f $selected.Category)
    Write-Host ("Synopsis:   {0}" -f $selected.Synopsis)
    Write-Host ("Runnable:   {0}" -f $selected.IsRunnable)
    Write-Host ""
    Write-Host $preview
    Write-Host ""

    if (-not $PreviewOnly) {
        Invoke-SelectedScript -Item $selected
    }

    $afterAction = Read-Host "Press Enter to continue, /filter to change filter, or q to quit"
    if ($afterAction -eq "q") { break }
    if ($afterAction.StartsWith("/")) {
        $currentFilter = $afterAction.TrimStart("/")
    }
}

