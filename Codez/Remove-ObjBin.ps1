<#

.SYNOPSIS

Removes bin,obj folders from provided directory

.EXAMPLE

PS > Remove-ObjBin
removes bin/obj from provided directory

.DESCRIPTION

Removes bin,obj folders from provided directory. If directory is not provided, current location of the folder is used.

Author for this script is Ardalis on below link:
https://ardalis.com/delete-bin-obj-folders-recursively/

#>

param(
    [Parameter(HelpMessage = "Provide the root path which contains bin,obj folders")]
    [string]    
    $Path,
    [switch]$RestartCurrentSession
)

Write-Information "Removing bin,obj folders from $Path"

if ($Path -eq "") {
    Write-Verbose "Path is not defined, use Get-Location option."
    $Path = Get-Location
}

$numberOfDirDeleted = 0
Get-ChildItem $Path -Directory -Include bin,obj -Recurse | ForEach-Object { 
    Remove-Item $_.FullName -Force -Recurse
    $numberOfDirDeleted++
 }

Write-Output "Number of directories deleted: $numberOfDirDeleted"
