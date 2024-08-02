<#

 .SYNOPSIS

Do Git Pull every folder inside root folder from GitHub

.DESCRIPTION

Traverse all Directories and do Git Pull from GitHub and show the result to the user. If the user wants to see the log, he can use the -ShowLog switch.
 
.EXAMPLE

PS > Get-PullFromGH.ps1

Get a list of directories inside from the current folder and do git pull from GitHub

.EXAMPLE

PS > Get-PullFromGH.ps1 -RootFolderPath "C:\Users\vrhovnik\Documents\GitHub"

Get a list of directories inside from the root folder and do git pull from GitHub

.EXAMPLE

PS > Get-PullFromGH.ps1 -RootFolderPath "C:\Users\vrhovnik\Documents\GitHub" -ShowLog

Get a list of directories inside from the root folder and do git pull from GitHub. After finished, show the log in notepad
   
.LINK

http://github.com/vrhovnik
 
#>
[CmdletBinding(DefaultParameterSetName = "Codez")]
[alias('gfgh')]
param(    
    [Parameter(Mandatory = $false)]
    $RootFolderPath,
    [Parameter(Mandatory=$false)]
    [switch]$ShowLog    
)
$logPath = "$HOME/Downloads/get-pullfromgh.log"
Start-Transcript -Path $logPath -Force
# get path you were in
$GoToDir = Get-Location
if ($null -eq $RootFolderPath)
{
    $RootFolderPath = Get-Location    
}

# check if RootFolderPath is a directory and exists
if (-not (Test-Path -Path $RootFolderPath -PathType Container))
{
    Write-Output "RootFolderPath $RootFolderPath is not a directory or does not exist"
    Stop-Transcript
    return
}

Write-Output "Getting list of directories from $RootFolderPath"
$directories = Get-ChildItem -Path $RootFolderPath -Directory
Write-Output "Found $($directories.Count) directories"
$numberOfDirectories = $directories.Count
$directories | ForEach-Object {
    Write-Output "Doing git pull in $($_.FullName)"
    Set-Location -Path $_.FullName
    git pull
    Write-Output "Done git pull in $($_.FullName)"
}
Set-Location -Path $GoToDir
Write-Output "Running git pull in $numberOfDirectories directories, exiting"
Stop-Transcript
if ($ShowLog)
{
    Start-Process "notepad" -ArgumentList $logPath 
}
else
{
    Write-Output "Log file is saved in $logPath"
}