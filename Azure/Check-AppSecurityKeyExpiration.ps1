<#

.SYNOPSIS

Check if there are any applications with security key expiration in the next days

.EXAMPLE

PS > Check-AppSecurityKeyExpiration 
connect PS remotely on VM in Azure with name VMName in resource group ResourceGroupName

.DESCRIPTION

Check if there are any applications with security key expiration in the next days and it is sorted
by expiration date


.PARAMETER NumberOfDays
Number of days to check for expiration

#>
[CmdletBinding(DefaultParameterSetName = "Azure")]
param(
    [Parameter(HelpMessage = "Provide the number of days to check")]
    [int]    
    $NumberOfDays = 30
)

Write-Host "Checking if there are any applications with security key expiration in the next $NumberOfDays days"

Get-AzureADApplication -All:$true | Select-Object AppId, DisplayName -ExpandProperty PasswordCredentials | 
Where-Object EndDate -lt (Get-Date).AddDays($NumberOfDays) | Sort-Object EndDate | Format-Table AppId, DisplayName, EndDate