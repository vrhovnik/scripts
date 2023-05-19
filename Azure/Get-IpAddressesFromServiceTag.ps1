<#

.SYNOPSIS

Getting back IP address ranges for specific Azure service

.EXAMPLE

PS > Get-IpAddressesFromServiceTag -RegionName WestEurope -ServiceName MicrosoftContainerRegistry 
Get IP for Azure Container Registry in West Europe


.DESCRIPTION

Getting back IP address ranges for specific Azure service

.PARAMETER RegionName
Region to check the ip addresses for

.PARAMETER ServiceName
Azure service name to check - services can be retrieved via Get-AzNetworkServiceTag -Location $RegionName call

#>
[CmdletBinding(DefaultParameterSetName = "Networking")]
param(
    [Parameter(HelpMessage = "Provide the Azure region name")]
    [string]    
    $RegionName = "WestEurope"    ,
    [Parameter(HelpMessage = "Provide azure service")]
    [string]    
    $ServiceName = "MicrosoftContainerRegistry"    
)

$ErrorActionPreference = "Stop"
Write-Verbose "Service name is $ServiceName"
Write-Output "Getting service tags for region $RegionName"
$serviceTags = Get-AzNetworkServiceTag -Location $RegionName
Write-Verbose $serviceTags

$service = $serviceTags.Values | Where-Object { $_.Name -eq $ServiceName  }
Write-Output $service
if ($null -eq $service) {
    Write-Error "Service $ServiceName not found, check service tags"
    Write-Output $serviceTags
    return
}
$service.Properties.AddressPrefixes