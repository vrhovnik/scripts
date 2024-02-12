<#

.SYNOPSIS

Identify the Application Insights type by ingestion type

.EXAMPLE

PS > Get-AppInsightsTypes -SubscriptionId 'Your Subscription ID'


.DESCRIPTION

Use the following script to identify your Application Insights resources by ingestion type. The script will output the Name, IngestionMode, Id, and Type of the Application Insights resources in your subscription.
You need to porvide SubscriptionId to check for Application Insights resources in that subscription.

.PARAMETER SubscriptionId
subscription Id where the Application Insights resources are located


#>
[CmdletBinding(DefaultParameterSetName = "Azure")]
param(    
    [Parameter(HelpMessage = "Subscription Id is requried", Mandatory = $true)]
    [string]$SubscriptionId
)

Write-Host "Checking for Application Insights resources in subscription $SubscriptionId"
Get-AzApplicationInsights -SubscriptionId $SubscriptionId | Format-Table -Property Name, IngestionMode, Id, @{label = 'Type'; expression = {
        if ([string]::IsNullOrEmpty($_.IngestionMode)) {
            'Unknown'
        }
        elseif ($_.IngestionMode -eq 'LogAnalytics') {
            'Workspace-based'
        }
        elseif ($_.IngestionMode -eq 'ApplicationInsights' -or $_.IngestionMode -eq 'ApplicationInsightsWithDiagnosticSettings') {
            'Classic'
        }
        else {
            'Unknown'
        }
    }
}