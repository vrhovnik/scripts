<#

.SYNOPSIS

Check if there are any applications with security key expiration in the next days

.EXAMPLE

PS > Get-AppSecurityKeyExpiration 
Check if there are any applications with security key expiration in the 30 days

.EXAMPLE

PS > Get-AppSecurityKeyExpiration -NumberOfDays 7
Check if there are any applications with security key expiration in last 7 days

.EXAMPLE

PS > Get-AppSecurityKeyExpiration -NumberOfDays 7 -InstallDependency
Check if there are any applications with security key expiration in last 7 days and install dependencies to MS Graph Module

.DESCRIPTION

Check if there are any applications with security key expiration in the next days and it is sorted
by expiration date

 You will need to have MS Graph Module installed 
 https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0

 If you don't have the module installed, you will get 

.PARAMETER NumberOfDays
Number of days to check for expiration

.PARAMETER InstallDependency
$true install Ms Graph module, $false outputs instructions and finishes the script

.LINK
https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0

#>
[CmdletBinding(DefaultParameterSetName = "MSGraph")]
param(
    [Parameter(HelpMessage = "Provide the number of days to check")]
    [int]    
    $NumberOfDays = 30, 
    [Parameter(HelpMessage = "Install module automatically", Mandatory = $false)]
    [switch]$InstallDependency
)

Write-Verbose "Checking if Microsoft.Graph module is installed"
$moduleInstalled = Get-InstalledModule -Name "Microsoft.Graph"
if ($null -eq $moduleInstalled) {
    Write-Host "Microsoft.Graph module is not installed."
    if ($InstallDependency)
    {
        Install-Module -Name "Microsoft.Graph" -Force
        Import-Module Microsoft.Graph
        Write-Host "Module installed, continuing with execution."
    }
    else{
        Write-Host "Module is not installed, please install it manually."
        Write-Host "You can install it by running the following command:"
        Write-Host "Install-Module -Name 'Microsoft.Graph' -Force"
        Write-Host "Exiting..."
        return
    }
}

Write-Output "Connecting to Microsoft Graph with read scope on applications"
Connect-MgGraph -Scopes "Application.Read.All"
Write-Verbose "Getting data from scope: $(Get-MgContext | Select-Object -Expand ContextScope)"
Write-Output "Checking if there are any applications with security key expiration in the next $NumberOfDays days"
Get-MgApplication | Select-Object AppId -ExpandProperty PasswordCredentials 
| Where-Object EndDateTime -lt (Get-Date).AddDays($NumberOfDays) 
| Sort-Object EndDateTime 
| Format-Table AppId, DisplayName, EndDateTime