<#

.SYNOPSIS

Get directories and files count

.EXAMPLE

PS > Get-Folder-Files-Count
get stats for current folder

PS > Get-Folder-Files-Count -folder "c:\Work"
get stats for specific folder

#>

param(
    ## provided folder
    [Parameter]
    [string]
    $folder
)

if ($folder -eq "") {
	$folder=Get-Location
}

$directories,$files = Get-ChildItem $folder -Force -Recurse | Measure-Object -Sum PSIsContainer, Length -ErrorAction Ignore
$directories,$files