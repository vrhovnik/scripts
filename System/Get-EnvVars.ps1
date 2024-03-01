<#

.SYNOPSIS

Get and set env files from env file

.EXAMPLE

PS > Get-EnvVars -EnvFile "c:\Work\test.env"

Get a list of environment variables from the test.env file and set them in the current session.

#>

[CmdletBinding(DefaultParameterSetName = "System")]
param(    
    [Parameter(HelpMessage = "File with env variables", Mandatory = $true)]
    [string]
    $EnvFile
)

if (!(Test-Path $EnvFile -PathType Leaf)) {
    Write-Error "$EnvFile is not a file."
    return;
}

Get-Content $EnvFile | ForEach-Object {
    $name, $value = $_.split('=')
    Write-Information "$name=$value"
    Set-Content env:\$name $value
    Write-Output "Writing $name to environment variable with $value."
}
