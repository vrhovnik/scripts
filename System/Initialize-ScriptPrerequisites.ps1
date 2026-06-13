<#
.SYNOPSIS
Checks and optionally installs prerequisites for this scripts repository.

.DESCRIPTION
Validates required and recommended tools/modules used across repository scripts.
By default, it runs in check-only mode and returns a status report.

.PARAMETER InstallMissingModules
Installs missing PowerShell modules (Az, Microsoft.Graph, Pester) in CurrentUser scope.

.PARAMETER InstallAzureCli
Installs Azure CLI using winget if missing and winget is available.

.EXAMPLE
Initialize-ScriptPrerequisites.ps1

.EXAMPLE
Initialize-ScriptPrerequisites.ps1 -InstallMissingModules -InstallAzureCli
#>
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$InstallMissingModules,

    [Parameter()]
    [switch]$InstallAzureCli
)

function New-StatusRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,

        [Parameter(Mandatory)]
        [string]$Type,

        [Parameter(Mandatory)]
        [bool]$Required,

        [Parameter(Mandatory)]
        [bool]$Installed,

        [Parameter()]
        [string]$Version = "",

        [Parameter()]
        [string]$InstallCommand = ""
    )

    [pscustomobject]@{
        Name           = $Name
        Type           = $Type
        Required       = $Required
        Installed      = $Installed
        Version        = $Version
        InstallCommand = $InstallCommand
    }
}

$results = New-Object System.Collections.Generic.List[object]

$pwshCompliant = $PSVersionTable.PSVersion -ge [version]"7.0.0"
$results.Add((New-StatusRecord -Name "PowerShell 7+" -Type "Runtime" -Required $true -Installed $pwshCompliant -Version $PSVersionTable.PSVersion.ToString() -InstallCommand "https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell"))

$requiredCommands = @(
    @{ Name = "git"; Required = $true; InstallCommand = "https://git-scm.com/downloads" },
    @{ Name = "winget"; Required = $false; InstallCommand = "https://learn.microsoft.com/en-us/windows/package-manager/winget/" },
    @{ Name = "choco"; Required = $false; InstallCommand = "https://chocolatey.org/install" },
    @{ Name = "docker"; Required = $false; InstallCommand = "https://www.docker.com/products/docker-desktop/" },
    @{ Name = "az"; Required = $false; InstallCommand = "https://learn.microsoft.com/en-us/cli/azure/install-azure-cli" },
    @{ Name = "kubectl"; Required = $false; InstallCommand = "https://kubernetes.io/docs/tasks/tools/" }
)

foreach ($commandInfo in $requiredCommands) {
    $command = Get-Command $commandInfo.Name -ErrorAction SilentlyContinue
    $version = ""
    if ($command) {
        $version = $command.Version.ToString()
    }

    $results.Add((
        New-StatusRecord `
            -Name $commandInfo.Name `
            -Type "Command" `
            -Required $commandInfo.Required `
            -Installed ([bool]$command) `
            -Version $version `
            -InstallCommand $commandInfo.InstallCommand
    ))
}

$moduleChecks = @(
    @{ Name = "Az"; Required = $false; InstallCommand = "Install-Module Az -Scope CurrentUser -Force" },
    @{ Name = "Microsoft.Graph"; Required = $false; InstallCommand = "Install-Module Microsoft.Graph -Scope CurrentUser -Force" },
    @{ Name = "Pester"; Required = $false; InstallCommand = "Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck" }
)

foreach ($moduleInfo in $moduleChecks) {
    $module = Get-Module -ListAvailable -Name $moduleInfo.Name | Sort-Object Version -Descending | Select-Object -First 1
    $moduleVersion = ""
    if ($module) {
        $moduleVersion = $module.Version.ToString()
    }

    $results.Add((
        New-StatusRecord `
            -Name $moduleInfo.Name `
            -Type "Module" `
            -Required $moduleInfo.Required `
            -Installed ([bool]$module) `
            -Version $moduleVersion `
            -InstallCommand $moduleInfo.InstallCommand
    ))

    if ($InstallMissingModules -and -not $module) {
        switch ($moduleInfo.Name) {
            "Az" { Install-Module Az -Scope CurrentUser -Force; break }
            "Microsoft.Graph" { Install-Module Microsoft.Graph -Scope CurrentUser -Force; break }
            "Pester" { Install-Module Pester -Scope CurrentUser -Force -SkipPublisherCheck; break }
        }
    }
}

$azCheck = $results | Where-Object { $_.Name -eq "az" }
$wingetCheck = $results | Where-Object { $_.Name -eq "winget" }
if ($InstallAzureCli -and -not $azCheck.Installed -and $wingetCheck.Installed) {
    winget install --id Microsoft.AzureCLI --source winget --accept-package-agreements --accept-source-agreements
}

$results | Sort-Object Type, Name | Format-Table -AutoSize
$results

