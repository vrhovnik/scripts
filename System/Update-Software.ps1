<#
.SYNOPSIS
  
Updates all the software on the system with chocolatey and winget with one command.
  
.DESCRIPTION
  
Updates all the software on the system with choco and winget by calling both package managers and updates the system.
  
.PARAMETER Confirm
Updates all the software on the system with chocolatey and winget and you need to confirm each step

.PARAMETER CheckIfChocolateyIsInstalled
Updates all the software on the system with chocolatey and winget and checks if you have chocolatey installed first. If not, it will only update winget packages.
  
.EXAMPLE
  
PS> Update-Software.ps1
Updates all the software on the system by chocolatey and winget
  
.EXAMPLE
  
PS> Update-Software -Confirm
Updates all the software and you need to confirm each step
  
.EXAMPLE
  
PS> Update-Software -CheckIfChocolateyIsInstalled
Updates all the software and check if Chocolatey is installed first and only updates winget packages.
  
#>
  
#Parameters
[CmdletBinding(DefaultParameterSetName = "System")]
param (
	[Parameter(Mandatory=$false)]
    [switch]
    $Confirm,
    [Parameter(Mandatory=$false)]
    [switch]
    $CheckIfChocolateyIsInstalled
)

# Test admin privileges without using -Requires RunAsAdministrator,
# which causes a nasty error message, if trying to load the function within a PS profile but without admin privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
	Write-Warning ("Function {0} needs admin privileges. Break now." -f $MyInvocation.MyCommand)
	return
}

# flag for installing chocolatey
$HasChocolateyBeenInstalled=$true

if ($CheckIfChocolateyIsInstalled) {
    Write-Host ("Checking if Chocolatey is installed in $env:ProgramData\Chocolatey folder") -ForegroundColor Green    
    if (-not (Test-Path -Path "$env:ProgramData\Chocolatey")) {
        # check if choco.exe exists in the path
        if (Get-Command choco.exe -ErrorAction SilentlyContinue) {
            $HasChocolateyBeenInstalled = $true
            Write-Host ("Chocolatey choco.exe command is installed in the system") -ForegroundColor Green
        }
        else {
            $HasChocolateyBeenInstalled = $false
            Write-Host ("Chocolatey is not installed. Please install it first at https://chocolatey.org to update choco packages....") -ForegroundColor Red
        }                        
    }
    else {
        Write-Host ("Chocolatey is installed, continuing with upgrading process....") -ForegroundColor Green
    }
}

Write-Host ("Starting with updating winget packages....") -ForegroundColor Green


if ($Confirm) {
    winget upgrade --all
    Write-Host ("Starting with updating chocolatey packages and you will need to confirm each step...") -ForegroundColor Green
    if ($HasChocolateyBeenInstalled) {
        choco upgrade all
    }
    else {
        Write-Host ("Chocolatey is not installed. Please install it first. Continuing with updating winget packages...") -ForegroundColor Red
    }    
}
else {
    # Update winget packages
    winget upgrade --all --accept-source-agreements    
    Write-Host ("Starting with updating chocolatey packages...") -ForegroundColor Green
    if ($HasChocolateyBeenInstalled) {
        choco upgrade all -y
    }    
}
if ($HasChocolateyBeenInstalled) {
    Write-Host ("Done with updating all software on the system with chocolatey and winget.") -ForegroundColor Green    
}
else {
    Write-Host ("Done with updating all software on the system with winget. To be able to run it with Chocolatey, you need to have that installed first at https://chocolatey.org.") -ForegroundColor Green    
}    
