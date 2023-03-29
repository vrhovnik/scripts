<#

.SYNOPSIS

Get installed software list

.EXAMPLE

PS > Get-InstalledSoftware
get stats for current folder

PS > Get-InstalledSoftware -SoftwareName "Dotnet"
get  information about installation software

#>

param(    
    [Parameter(HelpMessage = "Software name to get info if it is installed")]
    [string]$SoftwareName
)

Write-Verbose "Checking if software $SoftwareName is defined"
Write-Host ""
Write-Host "************************************************************************************************************************************************"
Write-Host ""
$SoftwareName = "*" + $SoftwareName + "*" 


Write-Verbose "Getting 32 bit software list for $SoftwareName"

$32bitsoftware = Get-ItemProperty HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*
| Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation 
| Where-Object -Property DisplayName -Like $SoftwareName

Write-Verbose "$32bitsoftware"

Write-Verbose "Getting 64 bit software list for $SoftwareName"
$64bitsoftware = Get-ItemProperty HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*
| Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation 
| Where-Object -Property DisplayName -Like $SoftwareName

Write-Verbose "$64bitsoftware"

Write-Verbose "Getting all software list for $SoftwareName"
Write-Host "32 bit software list for $SoftwareName" -ForegroundColor Red
$32bitsoftware | Format-Table -AutoSize

Write-Host "64 bit software list for $SoftwareName " -ForegroundColor Red 
$64bitsoftware | Format-Table -AutoSize
Write-Host "Done with getting back the software list for $SoftwareName" 
Write-Host ""
Write-Host "************************************************************************************************************************************************"
Write-Host ""
