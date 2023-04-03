<#

.SYNOPSIS

Get values from .env file and store them to environment variables

.EXAMPLE

PS > Get-EnvFromFile -EnvFileToReadFrom "sample.env"
get env from file and set them

#>

[CmdletBinding(DefaultParameterSetName = "System")]
param(
    [Parameter(HelpMessage = "Provide the name of the file to read", Mandatory=$true)]
    [string]    
    $EnvFileToReadFrom
)

if ("" -ne $EnvFileToReadFrom) {
    Write-Output "Filename is required."
    return;
}

#read the env file and set the environment variables    
Get-Content $EnvFileToReadFrom | ForEach-Object {
        $name, $value = $_.split('=')
        Set-Content env:\$name $value
}