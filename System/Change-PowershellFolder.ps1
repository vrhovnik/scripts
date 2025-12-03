<#

.SYNOPSIS

Change the current PowerShell folder to a specified path (does both for PowerShell core and PowerShell Windows).  
It can copy the profile script or create new if it does not exist.

.EXAMPLE

PS > Change-PowershellFolder -Path "C:\Work"
Changes the current PowerShell folder to C:\Work

.EXAMPLE

PS > Change-PowershellFolder -Path "C:\Work" -CreateIfNotExists
Changes the current PowerShell folder to C:\Work and creates the folder if it does not exist

.EXAMPLE

PS > Change-PowershellFolder -Path "C:\Work" -CreateIfNotExists -CopyProfile
Changes the current PowerShell folder to C:\Work and creates the folder if it does not exist. Also copies the profile script if it exists.

.DESCRIPTION
Changes the current PowerShell folder to a specified path and copies the profile script if it exists (does both for PowerShell core and PowerShell Windows)
If the path does not exist, it will output an error message. If you set flag CreateIfNotExist, it will create the folder if it does not exist. 

#>
[CmdletBinding(DefaultParameterSetName = "System")]
param(    
    [Parameter(HelpMessage = "Path to change the current PowerShell folder to", Mandatory = $true)]
    [string]$Path,
    [switch]$CreateIfNotExists,
    [switch]$CopyProfile
)

Write-Host "************************************************************************************************************************************************"
Write-Host "Checking for administrative privileges. "
If (!([Security.Principal.WindowsPrincipal]	[Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Start-Process -Verb RunAs wt.exe '-p "PowerShell"'
    Exit
}

Write-Verbose "Admin right confirmed. Checking $Path if it exists."
if (-Not (Test-Path -Path $Path)) {
    if ($CreateIfNotExist) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
        Write-Host "Created folder: $Path"
    }
    else {
        Write-Error "The specified path does not exist: $Path"
        return
    }
}

function Copy-Profile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourceProfilePath,
        [Parameter(Mandatory = $true)]
        [string]$DestinationFolderPath
    )

    # Check if source profile exists
    if (Test-Path -Path $SourceProfilePath) {
        $DestinationProfilePath = Join-Path -Path $DestinationFolderPath -ChildPath (Split-Path -Leaf $SourceProfilePath)
        Copy-Item -Path $SourceProfilePath -Destination $DestinationProfilePath -Force
        Write-Host "Copied profile script to: $DestinationProfilePath"
    }
    else {
        Write-Host "No profile script found at: $SourceProfilePath. Creating a new one at the new location."
        New-Item -ItemType File -Path (Join-Path -Path $DestinationFolderPath -ChildPath (Split-Path -Leaf $SourceProfilePath)) -Force | Out-Null
    }
}

function Add-FolderIfMissing {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        [string]$SoftwareName = "PowerShell"
    )

    # Define folder name and full path    
    $FullSoftwarePath = Join-Path -Path $Path -ChildPath $SoftwareName

    Write-Host "Changed folder to: $Path"

    # Check if folder exists
    if (-not (Test-Path -Path $FullSoftwarePath)) {
        # Create folder if missing
        New-Item -ItemType Directory -Path $FullSoftwarePath -Force | Out-Null
        Write-Host "Created PowerShell folder: $FullSoftwarePath"
    }
    else {
        Write-Host "PowerShell folder exists: $FullSoftwarePath"
    }

    # Return the full path for further use
    return $FullSoftwarePath
}

Set-Location -Path $Path
Write-Host "Setting the new PowerShell folder path in the registry."
New-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders' Personal -Value $Path -Type ExpandString -Force
Write-Host "New PowerShell folder path set in the registry. Adding PowerShell folders if missing."
$pwshCorePath = Add-FolderIfMissing -Path $Path -SoftwareName "PowerShell" 
Write-Host "Setting the new PowerShell Core folder path."
$pwshWindowsPath = Add-FolderIfMissing -Path $Path -SoftwareName "WindowsPowerShell" 
Write-Host "Setting the new Windows PowerShell folder path."

if (-Not $CopyProfile) {
    Write-Host "Skipping profile script copy as CopyProfile flag is not set and creating new clean profile."
    New-Item -ItemType File -Path (Join-Path -Path $pwshCorePath -ChildPath (Split-Path -Leaf $profilePath)) -Force | Out-Null
    Write-Host "Added PowerShell Core profile script at: $pwshCorePath"
    New-Item -ItemType File -Path (Join-Path -Path $pwshWindowsPath -ChildPath (Split-Path -Leaf $profilePath)) -Force | Out-Null
    Write-Host "Added Windows PowerShell profile script at: $pwshWindowsPath"
    return
}
else {
    Write-Host "Proceeding to copy profile scripts or create new ones."    
    $winPSProfile = Join-Path $env:USERPROFILE 'Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1'
    Write-Host "Checking for profile script at: $winPSProfile and copying it to the $pwshWindowsPath"
    Copy-Profile -SourceProfilePath $winPSProfile -DestinationFolderPath $pwshWindowsPath
    $corePSProfile = Join-Path $env:USERPROFILE 'Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
    Copy-Profile -SourceProfilePath $corePSProfile -DestinationFolderPath $pwshCorePath
}
Write-Host "************************************************************************************************************************************************"
Write-Host "Done with changing the path for PowerShell folder. Restart PowerShell to see the changes. " 
Write-Host ""
Write-Host "************************************************************************************************************************************************"
Write-Host ""
Read-Host -Prompt "Press Enter to continue"
Start-Process powershell -ArgumentList '-NoExit', '-Command', 'cat $PROFILE'
exit

