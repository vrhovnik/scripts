<#

.SYNOPSIS

Getting administrators, owners, coadmins of Azure Subscription

.EXAMPLE

PS > Get-Admins
Get administrators, owners, coadmins of Azure Subscription


.DESCRIPTION

Getting administrators, owners, coadmins of currently signed-in Azure Subscription

#>

Write-Information "Getting administrators, owners, coadmins of Azure Subscription"

$subName = Get-AzContext | Select-Object -ExpandProperty Subscription | Select-Object -ExpandProperty Name
Write-Host "Getting admins, contributors and coadmins of subscription $subName"
(Get-AzRoleAssignment -IncludeClassicAdministrators 
| Where-Object {$_.RoleDefinitionName -in @('ServiceAdministrator', 'CoAdministrator', 'Owner', 'Contributor') } 
| Select-Object -ExpandProperty SignInName | Sort-Object -Unique) -Join ", "