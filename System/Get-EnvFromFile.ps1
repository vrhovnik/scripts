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

Write-Verbose "Reading env file $EnvFileToReadFrom"
if ("" -ne $EnvFileToReadFrom) {
    Write-Output "Filename is required, aborting. Specify file to read variables from"
    return;
}

Write-Verbose "File has been specified, reading from $EnvFileToReadFrom"
#read the env file and set the environment variables    
Get-Content $EnvFileToReadFrom | ForEach-Object {
        $name, $value = $_.split('=')
        Write-Verbose "Setting environment variable $name to $value"
        Set-Content env:\$name $value
}
Write-Output "Environment variables set from $EnvFileToReadFrom"