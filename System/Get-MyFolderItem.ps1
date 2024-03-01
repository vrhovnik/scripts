<#

.SYNOPSIS

use the function to get a list of files and directories in a folder, sorted by last write time

.DESCRIPTION

function enables you to get a list of files and directories in a folder, sorted by last write time. It is a wrapper around Get-ChildItem and accepts all of its parameters. You can use it to get a list of files, directories, or both. 
You can also filter the results by file extension, and you can include or exclude specific files or directories. The function also supports recursion.

.EXAMPLE

PS > Get-MyFolderItem -Path c:\scripts -Recurse -File -Exclude *.ps1 | Select-Object -Last 3

Get a list of files in the c:\scripts folder and all subfolders, excluding any files with a .ps1 extension. Sort the results by last write time and select the last three files.

.EXAMPLE

PS > gfi -Path c:\scripts -Recurse -Directory -Include *test* | Select-Object -Last 3

Get a list of directories in the c:\scripts folder and all subfolders, including only those directories with "test" in the name. Sort the results by last write time and select the last three directories. It uses alias.

.LINK
https://jdhitsolutions.github.io/powershell

#>
Function Get-MyFolderItem {
    [CmdletBinding()]
    [Alias('gfi')]
    Param(
        [Parameter(Position = 0)]
        [String]$Path,
        [Parameter(Position = 1)]
        [String]$Filter,
        [Switch]$File,
        [Switch]$Directory,
        [string[]]$Exclude,
        [string[]]$Include,
        [Switch]$Recurse
    )
    #Run Get-ChildItem with whatever parameters are specified.
    Get-ChildItem @PSBoundParameters | Sort-Object -Property { -Not $_.PSIsContainer }, LastWriteTime
}
