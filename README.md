# Scripts I use daily on my Windows machine with PowerShell

Scripts I use daily, some authored, some borrowed from respective authors by their permission or by them sharing scripts publically.

Scripts are built in different folders, and are called from the root folder:

1. *Codez* - scripts to be used for coding assistance
2. *Random* - random scripts to get weather info, to help with other tasks
3. *System* - scripts to help with system administration like reading and setting env files, getting installed software, etc.
4. *RSS* - scripts to help with RSS feeds - read rss feeds, get latest news, etc.

To run the scripts you will need to have PowerShell installed on your machine. You can download it from [here](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell). I recommmend using [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/install) and [PowerToys](https://www.microsoft.com/en-us/powertoys/).

## Adding scripts to your system path

If you want for example run [Read-RssFeed.ps1](/RSS/Read-Rss.ps1), you would write Read-Rss.ps1 in your terminal:

```powershell
Read-Rss.ps1
```

PowerShell doesn't know where this script is located and you will get this error:

![Script not found](https://webeudatastorage.blob.core.windows.net/web/read-script-not-found-error.png)

To fix this, you need to add the root folder to your system path. You can do this manually, but I have a script for that. You can find it [here](/System/Add-DirToSystemEnv.ps1). You can run it from the root folder, or from any other folder. It will add the root folder and all sub-folders to your system path.

```powershell
Add-DirToSystemEnv.ps1 -RestartCurrentSession
```

The result is the following:

![Scripts added to system path](https://webeudatastorage.blob.core.windows.net/web/read-script-added-to-env-path.png)

## Additional links

```powershell

$powershell-docs = Start-Process "https://go.azuredemos.net/docs-pwsh-home"
$powershell-github = Start-Process "https://github.com/PowerShell/PowerShell.git"
$windows-terminal = Start-Process "https://go.azuredemos.net/docs-terminal-home"
$windows-terminal-github-page = Start-Process "https://github.com/microsoft/terminal.git"
$powershell-module-considerations = Start-Process "https://learn.microsoft.com/en-us/powershell/scripting/dev-cross-plat/performance/module-authoring-considerations?view=powershell-7.3"

```

# Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.