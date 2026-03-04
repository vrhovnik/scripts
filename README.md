# Scripts I Use Daily

[![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-blue?logo=powershell)](https://learn.microsoft.com/en-us/powershell/scripting/overview)
[![Platform](https://img.shields.io/badge/Platform-Windows-informational?logo=windows)](https://www.microsoft.com/windows)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A curated collection of PowerShell scripts for everyday tasks: Azure management, development tooling, container management, RSS reading, system administration, and more.

Scripts are organized into folders by topic. Add the root folder (and all subfolders) to your system `PATH` using the provided [`Add-DirToSystemEnv.ps1`](/System/Add-DirToSystemEnv.ps1) script so you can call any script by name from any directory.

## 📁 Folder Structure

| Folder | Description | README |
|--------|-------------|--------|
| [Azure](Azure/) | Azure management scripts (VMs, networking, App Insights, email) | [Azure/README.md](Azure/README.md) |
| [Codez](Codez/) | Development tools (build cleanup, Git pull, cheat sheets, containers) | [Codez/README.md](Codez/README.md) |
| [Containers](Containers/) | Docker container management (SQL Server in containers) | [Containers/README.md](Containers/README.md) |
| [Kubernetes](Kubernetes/) | Kubernetes command references | [Kubernetes/README.md](Kubernetes/README.md) |
| [Office](Office/) | Office document automation (extract images from Word) | [Office/README.md](Office/README.md) |
| [Profiles](Profiles/) | PowerShell profile configuration | [Profiles/README.md](Profiles/README.md) |
| [Random](Random/) | Miscellaneous utilities (weather, text-to-speech) | [Random/README.md](Random/README.md) |
| [RSS](RSS/) | RSS feed reader for the terminal | [RSS/README.md](RSS/README.md) |
| [System](System/) | System administration (PATH, env vars, software management) | [System/README.md](System/README.md) |

## 🚀 Getting Started

### Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell) — download and install for your platform
- [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/install) — recommended terminal (Windows)
- [PowerToys](https://learn.microsoft.com/en-us/windows/powertoys/install) — optional but recommended on Windows

### Adding scripts to your PATH

To call scripts from anywhere without specifying the full path, add the repository root and all subfolders to your `PATH`:

```powershell
.\System\Add-DirToSystemEnv.ps1 -PathToAdd "C:\path\to\scripts" -RestartCurrentSession
```

After running this, you can call any script by name:

```powershell
Read-Rss.ps1
Get-WeatherInfo.ps1
Remove-ObjBin.ps1
```

**Before:**

![Script not found](https://webeudatastorage.blob.core.windows.net/web/read-script-not-found-error.png)

**After:**

![Scripts added to system path](https://webeudatastorage.blob.core.windows.net/web/read-script-added-to-env-path.png)

### Azure scripts

Azure scripts require the [Azure PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps):

```powershell
Install-Module -Name Az -Scope CurrentUser -Force
Connect-AzAccount
```

## 🧪 Running Tests

Each folder that contains scripts has a `tests/` subfolder with [Pester](https://pester.dev/) tests.

```powershell
# Run tests for a single folder
Invoke-Pester -Path .\Azure\tests\Azure.Tests.ps1 -Output Detailed

# Run all tests
Invoke-Pester -Path .\Azure\tests, .\Codez\tests, .\Containers\tests, .\Office\tests, .\RSS\tests, .\Random\tests, .\System\tests -Output Normal
```

Tests validate script syntax, parameter definitions, help content, and (where possible) functional behavior — without requiring Azure credentials or external services.

## 📚 Additional Resources

| Resource | Link |
|----------|------|
| PowerShell documentation | [learn.microsoft.com/powershell](https://learn.microsoft.com/en-us/powershell/scripting/overview) |
| PowerShell GitHub repository | [github.com/PowerShell/PowerShell](https://github.com/PowerShell/PowerShell) |
| Windows Terminal | [learn.microsoft.com/windows/terminal](https://learn.microsoft.com/en-us/windows/terminal/) |
| Windows Terminal GitHub | [github.com/microsoft/terminal](https://github.com/microsoft/terminal) |
| PowerShell module authoring tips | [Module authoring considerations](https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/module-authoring-considerations?view=powershell-7.3) |
| Azure PowerShell | [learn.microsoft.com/powershell/azure](https://learn.microsoft.com/en-us/powershell/azure/) |
| Pester testing framework | [pester.dev](https://pester.dev/) |

## 🤝 Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
