# Copilot Instructions

## Repository Overview

A curated collection of PowerShell 7+ scripts for daily tasks, organized into topic folders: `Azure`, `Codez`, `Containers`, `Kubernetes`, `Office`, `Profiles`, `Random`, `RSS`, and `System`. Each folder has its own `README.md` and a `tests/` subfolder with [Pester](https://pester.dev/) tests.

## Running Tests

```powershell
# Run tests for a single folder
Invoke-Pester -Path .\Azure\tests\Azure.Tests.ps1 -Output Detailed

# Run a single Describe block by name
Invoke-Pester -Path .\Azure\tests\Azure.Tests.ps1 -Output Detailed -Filter "Connect-RemoteToVM.ps1"

# Run all tests across all folders
Invoke-Pester -Path .\Azure\tests, .\Codez\tests, .\Containers\tests, .\Office\tests, .\RSS\tests, .\Random\tests, .\System\tests -Output Normal
```

Tests validate syntax, parameter definitions, and help content. They do **not** require Azure credentials or external services.

## Prerequisites

```powershell
# Check only
.\System\Initialize-ScriptPrerequisites.ps1

# Check + install missing modules + Azure CLI
.\System\Initialize-ScriptPrerequisites.ps1 -InstallMissingModules -InstallAzureCli
```

Required modules: `Az`, `Microsoft.Graph`, `Pester`. Optional tools: `az` CLI, `docker`, `kubectl`, `winget`, `choco`.

## Script Conventions

### Comment-based help is required
Every `.ps1` script must have a `<# ... #>` comment block with at minimum `.SYNOPSIS` and `.EXAMPLE`. Tests assert this. The synopsis is also extracted by `Get-ScriptCatalog.ps1` for the script launcher UI.

### Standard structure
```powershell
<#
.SYNOPSIS
One-line description.

.DESCRIPTION
Extended description.

.PARAMETER ParamName
Explanation.

.EXAMPLE
PS > Script-Name.ps1 -Param value
What it does.
#>
[CmdletBinding(DefaultParameterSetName = "SetName")]
[alias('shortname')]  # optional shorthand alias
param(
    [Parameter(HelpMessage = "...", Mandatory = $true)]
    [string]$ParamName
)
```

### Aliases
Scripts that are called frequently define a `[alias('...')]` attribute (e.g., `rr` for `Read-Rss.ps1`, `rbo` for `Remove-ObjBin.ps1`). Add an alias for any new script intended for daily use.

### Verbose/Output pattern
Use `Write-Verbose` for diagnostic messages and `Write-Output` for user-visible results. Avoid `Write-Host` so output can be piped/captured.

### Azure scripts
- Always use `Az` module cmdlets (`Get-AzVM`, `Get-AzNetworkInterface`, etc.), not `az` CLI, unless the script is explicitly an install/setup helper.
- Call `Connect-AzAccount` implicitly (do not embed it in scripts); scripts assume the user is already authenticated.

## Catalog & Launcher

`System\Get-ScriptCatalog.ps1` scans all script extensions (`*.ps1`, `*.bat`, `*.sh`, `*.py`, `*.info`, etc.) and returns structured metadata. It is consumed by `System\Invoke-ScriptLauncher.ps1` for interactive search and execution.

```powershell
# Launch interactive script finder
.\System\Invoke-ScriptLauncher.ps1

# Start with a filter
.\System\Invoke-ScriptLauncher.ps1 -Search "azure"

# Export catalog as JSON
.\System\Get-ScriptCatalog.ps1 -AsJson | Set-Content .\scripts.catalog.json
```

## Adding Scripts to PATH

Run once to make all scripts callable from any directory:

```powershell
.\System\Add-DirToSystemEnv.ps1 -PathToAdd "C:\path\to\repo" -RestartCurrentSession
```

## Containers (`New-Database.ps1`, alias `cndb`)

Spins up a SQL Server container via Docker and wires up the connection string automatically.

- Uses `mcr.microsoft.com/mssql/server:2022-latest` by default; container image is overridable via `-ContainerName`.
- If `-InstanceName` is omitted, a random action-movie-inspired name is picked from a fixed list.
- SA password is validated against SQL Server policy (8–128 chars, ≥3 of: uppercase, lowercase, digit, symbol) **before** `docker run` is called.
- On success, the connection string is stored as a user environment variable `<DatabaseName>_ConnectionString` **and** copied to the clipboard.
- Pass `-PathToSqlScript` to run an initialization `.sql` file inside the container immediately after creation.
- Writes a transcript log to `$HOME/Downloads/create-new-database.log`.

```powershell
New-Database.ps1 -DatabaseName "MyDb" -SaPwd "MySecure@Pwd1"
New-Database.ps1 -DatabaseName "MyDb" -SaPwd "MySecure@Pwd1" -HostPort 1434 -Overwrite
New-Database.ps1 -DatabaseName "MyDb" -SaPwd "MySecure@Pwd1" -PathToSqlScript "C:\scripts\init.sql"
```

The Containers tests (`Containers\tests\Containers.Tests.ps1`) include functional tests for the SQL password policy function that run **without Docker**.

## Office (`Export-ImagesFromWord.ps1`)

Extracts embedded images from a `.docx` file **without requiring Microsoft Word** — it treats the file as a ZIP archive, unpacks `word/media/`, and parses `word/document.xml` for caption matching.

- The script defines a **function** (`Export-ImagesFromWord`), not a top-level script, so it must be dot-sourced before use:

```powershell
. .\Office\Export-ImagesFromWord.ps1
Export-ImagesFromWord -DocumentPath "C:\docs\report.docx" -Destination "C:\docs\images"
```

Returns objects with `Name`, `Figure`, `Caption`, `FullName` properties.

## RSS (`Read-Rss.ps1`, alias `rr`)

Fetches RSS items via `Invoke-RestMethod` and displays them sorted by publish date. Defaults to the Azure blog feed; accepts any RSS 2.0 URL. Tests in `RSS\tests\` use mocks — no network calls required.

```powershell
Read-Rss.ps1                                                   # last 10 items from Azure blog
Read-Rss.ps1 -Link "https://devblogs.microsoft.com/powershell/feed/" -LastItemCount 5
```

## Random

- `Get-WeatherInfo.ps1` — calls `wttr.in` via `Invoke-WebRequest`; no API key needed, location is auto-detected from IP.
- `Speak-Text.ps1` — uses `System.Speech.Synthesis.SpeechSynthesizer`; **Windows only**, will fail on Linux/macOS.

## PowerShell Profile

`Profiles\default-profile.ps1` is the profile template. It sets up aliases (`k` → `kubectl`, `azacc`, `myip`, `pdir`, `gpull`, etc.) and loads `posh-git`, `Terminal-Icons`, and `oh-my-posh`. Copy it to your `$PROFILE` path and adjust `$ScriptsRepoPath` if needed (defaults to the parent of the `Profiles` folder).
