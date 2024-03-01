<#

.SYNOPSIS

Get uptime for the system

.EXAMPLE

PS > Get-InstalledSoftware
get stats for current folder

.EXAMPLE 

PS > Get-UpTime 
get uptime for the system

.LINK
https://jeffhicks.substack.com/p/powershell-functions-101

#>
[CmdletBinding(DefaultParameterSetName = "System")]
[Alias('uptime')]
param(   
)

Write-Verbose "Getting uptime for the system"
$os = Get-CimInstance -ClassName Win32_OperatingSystem
Write-Verbose $os
$currentTime = New-TimeSpan -Start $os.LastBootUpTime -End (Get-Date)
Write-Verbose $currentTime
$currentTime
