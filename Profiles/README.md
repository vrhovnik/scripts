# Profiles

PowerShell profile scripts for customizing your shell environment.

## Files

### `default-profile.ps1`

A ready-to-use PowerShell profile that sets up a productive development environment on Windows. Copy the contents of this file (or include it with `. $HOME\path\to\default-profile.ps1`) in your `$PROFILE` file.

## What the profile sets up

### Environment Variables

| Variable      | Default Value                        | Description                 |
|---------------|--------------------------------------|-----------------------------|
| `CHOCODIR`    | `C:\ProgramData\chocolatey\lib\`     | Chocolatey packages path    |
| `WORKDIR`     | `C:\Work`                            | Root working directory      |
| `JMETER`      | `C:\Work\Tools\apache-jmeter-5.5\bin`| Apache JMeter binaries path |

### PSReadLine Configuration

Enables **inline** prediction view sourced from command history and plugins. Press <kbd>F2</kbd> to switch between prediction views.

📖 [PSReadLine documentation](https://learn.microsoft.com/en-us/powershell/module/psreadline/)

### Aliases

| Alias     | Command / Function               | Description                                 |
|-----------|----------------------------------|---------------------------------------------|
| `np`      | `notepad.exe`                    | Open Notepad                                |
| `k`       | `kubectl`                        | Kubernetes CLI                              |
| `azacc`   | `az account list --output table` | List Azure subscriptions                    |
| `myip`    | `Invoke-RestMethod ipinfo.io/json`| Get your public IP address                 |
| `wget`    | `Invoke-WebRequest`              | Download files from the web                 |
| `pdir`    | GoToPowershellDir                | Navigate to this scripts directory          |
| `home`    | `Set-Location $HOME`             | Go to home directory                        |
| `dwn`     | GoToDownloads                    | Navigate to Downloads folder                |
| `work`    | GoToWork                         | Navigate to `$WORKDIR`                      |
| `gdir`    | GoToGithub                       | Navigate to GitHub folder                   |
| `..`      | GoToOneBack                      | Navigate up one directory                   |
| `gpull`   | ExecuteGhPullWithSubfolders      | Git pull all repos under GitHub folder      |
| `lls`     | LoadLocalScript                  | Load scripts into current session PATH      |
| `glog`    | `git log --graph --oneline`      | Show compact git log graph                  |
| `gplog`   | GetGitPrettyLog                  | Show formatted git log graph                |
| `goadmin` | GoAdminFunc                      | Relaunch Windows Terminal as Administrator  |
| `godmode` | OpenGodModeFolder                | Open Windows God Mode folder                |
| `freeme`  | FreeDiskFolder                   | Open disk cleanup shortcut                  |

### Modules Imported

| Module           | Description                               |
|------------------|-------------------------------------------|
| `posh-git`       | Git status in the prompt                  |
| `Terminal-Icons` | File/folder icons in the terminal listing |
| `oh-my-posh`     | Customizable prompt themes                |

📖 [oh-my-posh documentation](https://ohmyposh.dev/)
📖 [posh-git on GitHub](https://github.com/dahlbyk/posh-git)
📖 [Terminal-Icons on GitHub](https://github.com/devblackops/Terminal-Icons)

## How to Use

1. Open your PowerShell profile for editing:

```powershell
notepad $PROFILE
```

2. Add the following line at the end:

```powershell
. "C:\path\to\scripts\Profiles\default-profile.ps1"
```

3. Reload your profile:

```powershell
. $PROFILE
```

## Additional Resources

- [About PowerShell profiles](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles)
- [PSReadLine](https://learn.microsoft.com/en-us/powershell/module/psreadline/)
- [Windows Terminal](https://learn.microsoft.com/en-us/windows/terminal/)
