# System Scripts

PowerShell scripts for Windows system administration: managing environment variables, finding installed software, checking system uptime, updating software, and more.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- Some scripts require **administrator privileges** (`Update-Modules.ps1`, `Update-Software.ps1`, `Sync-TimeWithWindows.ps1`)
- Some scripts are **Windows only** (`Get-InstalledSoftware.ps1`, `Get-WifiPassword.ps1`, `Get-UpTime.ps1`, `Max-Window.ps1`, `Sync-TimeWithWindows.ps1`)

## Scripts

### `Add-DirToSystemEnv.ps1`

Alias: `adtse`

Adds a directory and all of its subdirectories to `$env:Path` for the current session. Optionally reloads the PowerShell profile.

```powershell
# Add current directory and subdirectories to PATH
Add-DirToSystemEnv.ps1

# Add a specific directory
Add-DirToSystemEnv.ps1 -PathToAdd "C:\Work\my-daily-scripts"

# Add and reload the session profile
Add-DirToSystemEnv.ps1 -PathToAdd "C:\Work\my-daily-scripts" -RestartCurrentSession
```

📖 [About Environment Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables)

---

### `Change-PowershellFolder.ps1`

Changes the default starting folder for PowerShell sessions.

```powershell
Change-PowershellFolder.ps1
```

---

### `Count-FilePages.ps1`

Alias: `count-filepages`

Scans a folder (recursively) for PDF and DOCX files, counts their pages, and exports a summary CSV.

> **Requires:** [pdfinfo](https://www.xpdfreader.com/download.html) for PDF page counting.

```powershell
Count-FilePages.ps1 -Folder "C:\docs" -PdfInfoPath "C:\tools\pdfinfo.exe"
```

📖 [xpdf / pdfinfo](https://www.xpdfreader.com/download.html)

---

### `Get-EnvFromFile.ps1`

Reads a `.env` file and loads all key=value pairs as environment variables in the current session.

```powershell
Get-EnvFromFile -EnvFileToReadFrom "sample.env"
```

---

### `Get-EnvVars.ps1`

Reads a `.env` file and sets each `KEY=VALUE` pair as an environment variable in the current session.

```powershell
Get-EnvVars -EnvFile "C:\Work\.env"
```

Format of the `.env` file:
```env
MY_API_KEY=abc123
DATABASE_URL=Server=localhost;Database=mydb
```

---

### `Get-FolderFilesCount.ps1`

Alias: `gfc`

Counts the number of files and directories in a given folder (recursively).

```powershell
# Count in current folder
Get-FolderFilesCount.ps1

# Count in a specific folder
Get-FolderFilesCount.ps1 -Folder "C:\Work"
```

---

### `Get-InstalledSoftware.ps1`

Lists all installed software on the machine by querying the Windows registry. Supports filtering by name.

> ⚠️ **Windows only**

```powershell
# List all installed software
Get-InstalledSoftware.ps1

# Filter by name
Get-InstalledSoftware.ps1 -SoftwareName "Visual Studio"
```

📖 [Windows Registry](https://learn.microsoft.com/en-us/windows/win32/sysinfo/registry)

---

### `Get-MyFolderItem.ps1`

Alias: `gfi`

A wrapper around `Get-ChildItem` that sorts results by `LastWriteTime`. Accepts all `Get-ChildItem` parameters including `-File`, `-Directory`, `-Filter`, `-Include`, `-Exclude`, and `-Recurse`.

```powershell
# List all items sorted by last write time
Get-MyFolderItem -Path C:\scripts

# List only files modified recently, excluding test scripts
Get-MyFolderItem -Path C:\scripts -Recurse -File -Exclude *.test.ps1 | Select-Object -Last 5

# Using the alias
gfi -Path C:\scripts -Directory -Recurse | Select-Object -Last 3
```

📖 [Get-ChildItem documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/get-childitem)

---

### `Get-UpTime.ps1`

Alias: `uptime`

Returns the system uptime as a `TimeSpan` object by querying the last boot time from WMI.

> ⚠️ **Windows only** — uses `Win32_OperatingSystem` WMI class.

```powershell
Get-UpTime.ps1
```

📖 [Win32_OperatingSystem WMI class](https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-operatingsystem)

---

### `Get-WifiPassword.ps1`

Displays all stored Wi-Fi passwords on the machine using `netsh wlan export profile`.

> ⚠️ **Windows only** — requires `netsh` (Windows built-in).

```powershell
# Import the function
. .\Get-WifiPassword.ps1

# Show all Wi-Fi passwords
Get-WifiPassword
```

Based on the work from [HCRitter/Get-WIFIPassword](https://github.com/HCRitter/Get-WIFIPassword).

---

### `Max-Window.ps1`

Alias: `mw`

Finds a running process by name and maximizes its window using the Windows `user32.dll` API.

> ⚠️ **Windows only** — uses P/Invoke to call `ShowWindowAsync` and `SetForegroundWindow`.

```powershell
Max-Window.ps1 -ProcessName "notepad"
Max-Window.ps1 -ProcessName "devenv"
```

---

### `Search-StartMenu.ps1`

Searches both the user and all-users Start Menu folders for shortcuts matching a pattern.

> ⚠️ **Windows only**

```powershell
# Search and run the first match
Search-StartMenu "Character Map" | Invoke-Item

# Search interactively
Search-StartMenu "PowerShell" | Select-FilteredObject | Invoke-Item
```

---

### `Sync-TimeWithWindows.ps1`

Synchronizes the system clock with `time.windows.com` using the Windows Time service (`w32tm`).

> ⚠️ **Windows only — requires Administrator privileges**

```powershell
Sync-TimeWithWindows.ps1
```

📖 [Windows Time service](https://learn.microsoft.com/en-us/windows-server/networking/windows-time-service/windows-time-service-top)

---

### `Update-Modules.ps1`

Updates all installed PowerShell modules to their latest version and removes older installed versions.

> **Requires Administrator privileges**

```powershell
# Update to latest stable release
Update-Modules.ps1

# Update to latest prerelease version
Update-Modules.ps1 -AllowPrerelease
```

Based on a script from [powershellisfun.com](https://powershellisfun.com).

📖 [Update-Module documentation](https://learn.microsoft.com/en-us/powershell/module/powershellget/update-module)

---

### `Update-Software.ps1`

Updates all installed software using both **Winget** and **Chocolatey** package managers in a single command.

> **Requires Administrator privileges**

```powershell
# Update all software silently
Update-Software.ps1

# Update with confirmation prompts
Update-Software.ps1 -Confirm

# Check if Chocolatey is installed before trying to use it
Update-Software.ps1 -CheckIfChocolateyIsInstalled
```

📖 [winget documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
📖 [Chocolatey documentation](https://docs.chocolatey.org/en-us/)

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/System.Tests.ps1 -Output Detailed
```

Tests include syntax validation, parameter checks, and functional tests for:
- `Add-DirToSystemEnv.ps1` — validates directory is added to PATH
- `Get-EnvVars.ps1` — validates env file parsing and variable setting
- `Get-FolderFilesCount.ps1` — validates folder scanning
- `Get-MyFolderItem.ps1` — validates function definition and file listing

## Additional Resources

- [PowerShell Execution Policies](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies)
- [About Environment Variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables)
- [winget package manager](https://learn.microsoft.com/en-us/windows/package-manager/winget/)
- [Chocolatey package manager](https://chocolatey.org/)
