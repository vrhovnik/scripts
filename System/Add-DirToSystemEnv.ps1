<#

.SYNOPSIS

Add path to system environment variables

.EXAMPLE

PS > Add-DirToSystemEnv -PathToAdd "C:\Work\my-daily-scripts"
add folder to system environment variables

#>

param(
    [Parameter(HelpMessage = "Provide the path to add to system environment")]
    [string]    
    $PathToAdd,
    [switch]$RestartCurrentSession
)

if ($PathToAdd -eq "") {
    Write-Verbose "Path to add is not defined, use Get-Location optin."
    $PathToAdd = Get-Location
}

Write-Verbose "Path to add: $PathToAdd"

Get-ChildItem -Path $PathToAdd -Recurse -Directory | ForEach-Object {
    $path = $_.FullName
    Write-Verbose "Path to add: $path"
    $env:Path += ";$path"
}

if ($RestartCurrentSession) {
    Write-Verbose "Restarting current session."
    . $profile
}

Write-Output "Directory added to system environment variables."