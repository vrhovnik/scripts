<#

 .SYNOPSIS

Do Git Pull every folder inside root folder from GitHub

.DESCRIPTION

Traverse all Directories and do Git Pull from GitHub and show the result to the user. If the user wants to see the log, he can use the -ShowLog switch.
If a merge conflict is detected and DiscardChanges is true (default), local changes are discarded via git reset --hard and git clean -fd, then git pull is retried.
 
.EXAMPLE

PS > Get-PullFromGH.ps1

Get a list of directories inside from the current folder and do git pull from GitHub

.EXAMPLE

PS > Get-PullFromGH.ps1 -RootFolderPath "C:\Users\vrhovnik\Documents\GitHub"

Get a list of directories inside from the root folder and do git pull from GitHub

.EXAMPLE

PS > Get-PullFromGH.ps1 -RootFolderPath "C:\Users\vrhovnik\Documents\GitHub" -ShowLog

Get a list of directories inside from the root folder and do git pull from GitHub. After finished, show the log in notepad

.EXAMPLE

PS > Get-PullFromGH.ps1 -RootFolderPath "C:\Users\vrhovnik\Documents\GitHub" -DiscardChanges $false

Get a list of directories inside from the root folder and do git pull from GitHub. On conflict, log and continue without discarding local changes.
   
.LINK

http://github.com/vrhovnik
 
#>
[CmdletBinding(DefaultParameterSetName = "Codez")]
[alias('gfgh')]
param(    
    [Parameter(Mandatory = $false)]
    $RootFolderPath,
    [Parameter(Mandatory = $false)]
    [switch]$ShowLog,
    [Parameter(Mandatory = $false)]
    [bool]$DiscardChanges = $true
)
$logPath = "$HOME/Downloads/get-pullfromgh.log"
# get path you were in
$GoToDir = Get-Location
if ($null -eq $RootFolderPath)
{
    $RootFolderPath = Get-Location    
}

Add-Content -Path $logPath -Value "Starting git pull in $RootFolderPath"

# check if RootFolderPath is a directory and exists
if (-not (Test-Path -Path $RootFolderPath -PathType Container))
{
    Write-Output "RootFolderPath $RootFolderPath is not a directory or does not exist"
    Add-Content -Path $logPath -Value "RootFolderPath $RootFolderPath is not a directory or does not exist"
    return
}

Write-Output "Getting list of directories from $RootFolderPath"
Add-Content -Path $logPath -Value "Getting list of directories from $RootFolderPath"
$directories = Get-ChildItem -Path $RootFolderPath -Directory
Write-Output "Found $($directories.Count) directories"
Add-Content -Path $logPath -Value "Found $($directories.Count) directories"
$numberOfDirectories = $directories.Count

$directories | ForEach-Object {
    $dirPath = $_.FullName
    Write-Output "Doing git pull in $dirPath"
    Add-Content -Path $logPath -Value "Doing git pull in $dirPath"
    Set-Location -Path $dirPath

    $pullOutput = git pull 2>&1
    $pullOutput | ForEach-Object { Write-Output "[$dirPath] $_" }
    $pullOutput | Out-File -FilePath $logPath -Append

    $hasUnrelatedHistories = $pullOutput | Where-Object { $_ -match "refusing to merge unrelated histories" }
    $hasConflict = (-not $hasUnrelatedHistories) -and (($LASTEXITCODE -ne 0) -or ($pullOutput | Where-Object { $_ -match "CONFLICT|Automatic merge failed|unmerged files|unresolved conflict|would be overwritten by merge" }))

    if ($hasUnrelatedHistories) {
        if ($DiscardChanges) {
            Write-Output "[$dirPath] Unrelated histories detected - retrying with --allow-unrelated-histories"
            Add-Content -Path $logPath -Value "Unrelated histories detected in $dirPath - retrying with --allow-unrelated-histories"
            $retryOutput = git pull --allow-unrelated-histories 2>&1
            $retryOutput | ForEach-Object { Write-Output "[$dirPath] $_" }
            $retryOutput | Out-File -FilePath $logPath -Append
            Write-Output "[$dirPath] Retry pull completed"
            Add-Content -Path $logPath -Value "Retry pull completed in $dirPath"
        } else {
            Write-Output "[$dirPath] Unrelated histories detected - skipping (DiscardChanges is false)"
            Add-Content -Path $logPath -Value "Unrelated histories detected in $dirPath - skipping (DiscardChanges is false)"
        }
    } elseif ($hasConflict) {
        if ($DiscardChanges) {
            Write-Output "[$dirPath] Merge conflict detected - discarding local changes and retrying"
            Add-Content -Path $logPath -Value "Merge conflict detected in $dirPath - discarding local changes and retrying"
            git reset --hard HEAD 2>&1 | Out-File -FilePath $logPath -Append
            git clean -fd 2>&1 | Out-File -FilePath $logPath -Append
            $retryOutput = git pull 2>&1
            $retryOutput | ForEach-Object { Write-Output "[$dirPath] $_" }
            $retryOutput | Out-File -FilePath $logPath -Append
            Write-Output "[$dirPath] Retry pull completed"
            Add-Content -Path $logPath -Value "Retry pull completed in $dirPath"
        } else {
            Write-Output "[$dirPath] Merge conflict detected - skipping (DiscardChanges is false)"
            Add-Content -Path $logPath -Value "Merge conflict detected in $dirPath - skipping (DiscardChanges is false)"
        }
    }

    $numberOfDirectories--
    Write-Output "[$dirPath] Git pull finished, $numberOfDirectories directories left"
    Add-Content -Path $logPath -Value "Git pull finished in $dirPath, $numberOfDirectories directories left"
}
Set-Location -Path $GoToDir
Write-Output "Running git pull in $($directories.Count) directories, exiting"
Add-Content -Path $logPath -Value "Running git pull in $($directories.Count) directories."

if ($ShowLog)
{     
    Start-Process "notepad" -ArgumentList $logPath 
}
else
{    
    Write-Output "Log file is saved in $logPath"
}