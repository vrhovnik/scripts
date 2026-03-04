# Codez Scripts

PowerShell scripts that assist with daily development tasks: compiling containers, managing Git repositories, cleaning build artifacts, and searching documentation.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- [Git](https://git-scm.com/downloads) (for `Get-PullFromGH.ps1`)
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) (for `Compile-Containers.ps1`)

## Scripts

### `Compile-Containers.ps1`

Alias: `azcc`

Builds container images using Azure Container Registry (ACR) Tasks. Iterates over a folder of Dockerfiles and queues the builds on ACR.

```powershell
# Use defaults (resource group: monitoring-rg, registry: acr-monitoring)
Compile-Containers.ps1

# Custom settings
Compile-Containers.ps1 `
    -ResourceGroupName "my-rg" `
    -RegistryName "myregistry" `
    -FolderName "containers" `
    -TagName "v1.0" `
    -SourceFolder "src"
```

📖 [Azure Container Registry Tasks](https://learn.microsoft.com/en-us/azure/container-registry/container-registry-tasks-overview)

---

### `Create-IISExpressCert.ps1`

Creates a new self-signed TLS certificate for IIS Express development, removes the old certificate, and binds the new certificate to ports 44300–44399.

```powershell
Create-IISExpressCert.ps1
```

📖 [Develop locally with HTTPS using IIS Express](https://learn.microsoft.com/en-us/aspnet/core/security/enforcing-ssl#trust-the-aspnet-core-https-development-certificate-on-windows-and-macos)

---

### `executecs.bat`

Batch file to compile and run a C# file using the .NET compiler (`csc.exe`).

---

### `Get-PullFromGH.ps1`

Alias: `gfgh`

Traverses all subdirectories of a root folder and runs `git pull` in each one. Optionally opens the log file in Notepad afterwards.

```powershell
# Pull in all repos under the current folder
Get-PullFromGH.ps1

# Pull in all repos under a specific folder
Get-PullFromGH.ps1 -RootFolderPath "C:\Work\GitHub"

# Pull and open log in Notepad
Get-PullFromGH.ps1 -RootFolderPath "C:\Work\GitHub" -ShowLog
```

📖 [Git documentation](https://git-scm.com/docs/git-pull)

---

### `Remove-ObjBin.ps1`

Alias: `rbo`

Recursively removes all `bin` and `obj` folders from a given directory. Useful for cleaning up .NET build artifacts before archiving or sharing a project.

Original concept by [Ardalis](https://ardalis.com/delete-bin-obj-folders-recursively/).

```powershell
# Remove from current directory
Remove-ObjBin.ps1

# Remove from a specific path
Remove-ObjBin.ps1 -Path "C:\Work\MyProject"
```

📖 [.NET build output folders](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-build)

---

### `Search-CheatSheet.ps1`

Alias: `cheat`

Queries [cheat.sh](https://cheat.sh) and displays the result directly in the terminal — a quick way to look up command-line usage without leaving PowerShell.

```powershell
Search-CheatSheet -Query "pwsh"
Search-CheatSheet -Query "git"
Search-CheatSheet -Query "docker"
```

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/Codez.Tests.ps1 -Output Detailed
```

Tests include syntax validation, parameter checks, and functional tests for `Remove-ObjBin.ps1` and `Get-PullFromGH.ps1`.

## Additional Resources

- [PowerShell 7 documentation](https://learn.microsoft.com/en-us/powershell/scripting/overview)
- [Git documentation](https://git-scm.com/doc)
- [Azure Container Registry](https://learn.microsoft.com/en-us/azure/container-registry/)
- [cheat.sh](https://cheat.sh)
