<#

.SYNOPSIS

Get directories and files count

.EXAMPLE

PS > Get-Folder-Files-Count
get stats for current folder

PS > Get-Folder-Files-Count -Folder "c:\Work"
get stats for specific folder

#>

param(    
    [Parameter(HelpMessage="Folder to get stats for")]
    [string]$Folder
)

Write-Host "Reading folder $Folder"
if ($Folder -eq "") {
	$Folder=Get-Location
    Write-Verbose "Input folder is empty, using current folder $Folder"
}
# $directories,$files = Get-ChildItem $folder -Force -Recurse | Measure-Object -Sum PSIsContainer, Length -ErrorAction Ignore
$directories = Get-ChildItem -Path $Folder -Directory -Recurse | Measure-Object -Sum PSIsContainer -ErrorAction Ignore
$files = Get-ChildItem -Path $Folder -File -Recurse | Measure-Object -Sum Name -ErrorAction Ignore
Write-Verbose  $directories
Write-Verbose  $files

$properties = @{
    "Directories" = $directories.Count -as [int]
    "Files" = $files.Count -as [int]
}


$outputObject = New-Object psobject -Property $properties;
Write-Verbose "Output object: $outputObject"
$outputObject | Format-Table -AutoSize

