<#
.SYNOPSIS
Default PowerShell profile template for this scripts repository.

.DESCRIPTION
Configures common aliases, navigation helpers, prompt modules, and helper commands
for daily development workflows without hardcoding a single machine-specific repo path.

.PARAMETER ScriptsRepoPath
Optional path to this scripts repository root. If omitted, it is inferred from this file location.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$ScriptsRepoPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

function Set-DefaultEnvVar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(Mandatory)]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace((Get-Item -Path "Env:$Name" -ErrorAction SilentlyContinue).Value)) {
        Set-Item -Path "Env:$Name" -Value $Value
    }
}

Set-DefaultEnvVar -Name "CHOCODIR" -Value "C:\ProgramData\chocolatey\lib\"
Set-DefaultEnvVar -Name "WORKDIR" -Value "C:\Work"
Set-DefaultEnvVar -Name "JMETER" -Value "$ENV:WORKDIR\Tools\apache-jmeter-5.5\bin"

if (Get-Command Set-PSReadLineOption -ErrorAction SilentlyContinue) {
    Set-PSReadLineOption -PredictionSource HistoryAndPlugin -PredictionViewStyle InlineView
    Set-PSReadLineKeyHandler -Chord F2 -Function SwitchPredictionView
}

Set-Alias -Name np -Value C:\Windows\notepad.exe
Set-Alias -Name k -Value kubectl -ErrorAction SilentlyContinue
Set-Alias -Name wget -Value Invoke-WebRequest

function ShowAzAccounts { az account list --output table }
Set-Alias -Name azacc -Value ShowAzAccounts

function GetMyIP { Invoke-RestMethod https://ipinfo.io/json | Select-Object -ExpandProperty ip }
Set-Alias -Name myip -Value GetMyIP

function DoListWithAttributesAndList {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = "."
    )

    Get-ChildItem -LiteralPath $Path -Force -ErrorAction Stop |
        Sort-Object @{ Expression = { -not $_.PSIsContainer } }, Name |
        Format-Table -AutoSize `
            Mode, `
            @{ Label = "Size"; Expression = {
                if ($_.PSIsContainer) {
                    "<DIR>"
                }
                elseif ($_.Length -ge 1GB) {
                    "{0:N1} GB" -f ($_.Length / 1GB)
                }
                elseif ($_.Length -ge 1MB) {
                    "{0:N1} MB" -f ($_.Length / 1MB)
                }
                elseif ($_.Length -ge 1KB) {
                    "{0:N1} KB" -f ($_.Length / 1KB)
                }
                else {
                    "{0} B" -f $_.Length
                }
            }}, `
            LastWriteTime, Attributes, Name
}
Set-Alias -Name lsa -Value DoListWithAttributesAndList

function GroupBasedOnExtension {
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = "."
    )

    $directory = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
    if (-not $directory.PSIsContainer) {
        throw "'$Path' is not a directory."
    }

    $items = @(Get-ChildItem -LiteralPath $directory.FullName -Force -ErrorAction Stop)
    $folders = @($items | Where-Object PSIsContainer | Sort-Object Name)
    $files = @($items | Where-Object { -not $_.PSIsContainer })
    $rule = "─" * 72

    Write-Host "`n$($PSStyle.Foreground.Cyan)$($directory.FullName)$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.DarkGray)$rule$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.Yellow)FOLDERS$($PSStyle.Reset)  ($($folders.Count))"

    if ($folders.Count -eq 0) {
        Write-Host "  (none)" -ForegroundColor DarkGray
    }
    else {
        foreach ($folder in $folders) {
            $fileCount = 0L
            $subfolderCount = 0L
            $totalBytes = 0L

            Get-ChildItem -LiteralPath $folder.FullName -Force -Recurse -ErrorAction Stop |
                ForEach-Object {
                    if ($_.PSIsContainer) {
                        $subfolderCount++
                    }
                    else {
                        $fileCount++
                        $totalBytes += $_.Length
                    }
                }

            if ($totalBytes -ge 1GB) {
                $size = "{0:N1} GB" -f ($totalBytes / 1GB)
            }
            elseif ($totalBytes -ge 1MB) {
                $size = "{0:N1} MB" -f ($totalBytes / 1MB)
            }
            elseif ($totalBytes -ge 1KB) {
                $size = "{0:N1} KB" -f ($totalBytes / 1KB)
            }
            else {
                $size = "{0} B" -f $totalBytes
            }

            Write-Host ("  {0,-32} {1,6} files  {2,5} folders  {3,10}  {4}" -f
                $folder.Name, $fileCount, $subfolderCount, $size, $folder.LastWriteTime.ToString("yyyy-MM-dd HH:mm"))
        }
    }

    Write-Host "$($PSStyle.Foreground.DarkGray)$rule$($PSStyle.Reset)"
    Write-Host "$($PSStyle.Foreground.Yellow)FILES$($PSStyle.Reset)  ($($files.Count))"

    if ($files.Count -eq 0) {
        Write-Host "  (none)" -ForegroundColor DarkGray
        return
    }

    $groups = $files | Group-Object {
        if ([string]::IsNullOrEmpty($_.Extension)) { "[no extension]" } else { $_.Extension }
    } | Sort-Object Name

    foreach ($group in $groups) {
        Write-Host "`n$($PSStyle.Foreground.Green)$($group.Name)$($PSStyle.Reset)  ($($group.Count))"
        foreach ($file in ($group.Group | Sort-Object Name)) {
            if ($file.Length -ge 1GB) {
                $size = "{0:N1} GB" -f ($file.Length / 1GB)
            }
            elseif ($file.Length -ge 1MB) {
                $size = "{0:N1} MB" -f ($file.Length / 1MB)
            }
            elseif ($file.Length -ge 1KB) {
                $size = "{0:N1} KB" -f ($file.Length / 1KB)
            }
            else {
                $size = "{0} B" -f $file.Length
            }

            Write-Host ("  {0,10}  {1,-16} {2}" -f
                $size, $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm"), $file.Name)
        }
    }
}
Set-Alias -Name lsg -Value GroupBasedOnExtension

function GoToPowershellDir { Set-Location $ScriptsRepoPath }
Set-Alias -Name pdir -Value GoToPowershellDir

function GoHome { Set-Location $HOME }
Set-Alias -Name home -Value GoHome

function GoToDownloads { Set-Location "$HOME\Downloads" }
Set-Alias -Name dwn -Value GoToDownloads

function GoToWork { Set-Location $ENV:WORKDIR }
Set-Alias -Name work -Value GoToWork

function GoToGithub { Set-Location "$ENV:WORKDIR\Github" }
Set-Alias -Name gdir -Value GoToGithub

function GoToWorkFolder { Set-Location "$ENV:WORKDIR\" }
Set-Alias -Name wdir -Value GoToWorkFolder

function GoToProjects { Set-Location "$ENV:WORKDIR\Projects" }
Set-Alias -Name proj -Value GoToProjects

function GoToLocalTools { Set-Location "$ENV:WORKDIR\Tools" }
Set-Alias -Name tools -Value GoToLocalTools

function GoToOneBack { Set-Location .. }
Set-Alias -Name .. -Value GoToOneBack

function LoadLocalScript {
    $originalDir = Get-Location
    Set-Location $ScriptsRepoPath
    .\System\Add-DirToSystemEnv.ps1 -PathToAdd $ScriptsRepoPath -RestartCurrentSession
    Set-Location $originalDir
}
Set-Alias -Name lls -Value LoadLocalScript

function ExecuteGhPullWithSubfolders([bool]$DiscardChanges = $true) {
    $originalDir = Get-Location
    $scriptPath = Join-Path $ScriptsRepoPath "Codez\Get-PullFromGH.ps1"
    GoToGithub
    $directories = Get-ChildItem -Path $PWD -Directory
    foreach ($directory in $directories) {
        & $scriptPath -RootFolderPath $directory.FullName -DiscardChanges $DiscardChanges
    }
    Set-Location -Path $originalDir
}
Set-Alias -Name gpull -Value ExecuteGhPullWithSubfolders

function GetGitLog { git log --graph --oneline }
Set-Alias -Name glog -Value GetGitLog

function GetGitPrettyLog {
    git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset' --abbrev-commit --date=relative
}
Set-Alias -Name gplog -Value GetGitPrettyLog

function GoAdminFunc {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Start-Process -Verb RunAs wt.exe '-p "PowerShell"'
        exit
    }
}
Set-Alias -Name goadmin -Value GoAdminFunc

function OpenGodModeFolder {
    Set-Location "$ENV:OneDrive\Desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"
    Start-Process Explorer .
    Set-Location $HOME
}
Set-Alias -Name godmode -Value OpenGodModeFolder

function FreeDiskFolder {
    Set-Location "$ENV:OneDrive"
    Start-Process '.\Free up disk space by deleting unnecessary files - Shortcut.lnk'
    Set-Location $HOME
}
Set-Alias -Name freeme -Value FreeDiskFolder

if (Get-Module -ListAvailable -Name posh-git) { Import-Module posh-git }
if (Get-Module -ListAvailable -Name Terminal-Icons) { Import-Module Terminal-Icons }
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    oh-my-posh init pwsh --config "$ENV:POSH_THEMES_PATH\material.omp.json" | Invoke-Expression
}
