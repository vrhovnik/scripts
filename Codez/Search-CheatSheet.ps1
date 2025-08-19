<#

.SYNOPSIS

Search the cheat sheet website cheat.sh and give back the result in pwsh

.EXAMPLE

PS > Search-CheatSheet "pwsh"
Searches for the "pwsh" application, and then give back the result


#>
[CmdletBinding(DefaultParameterSetName = "Codez")]
[Alias('cheat')]
param(
    ## The string to search for
    [Parameter(Mandatory = $true)]
    $Query
)

Set-StrictMode -Version 3
try {
    Invoke-WebRequest cheat.sh/$Query | Select-Object -ExpandProperty Content
}
catch{
	Write-Out "There has been an error by calling cheat.sh. Check errors"
}