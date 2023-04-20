<#

.SYNOPSIS

Start virtual machine in Azure

.EXAMPLE

PS > Start-Machine -VmName "VMName" -ResourceGroupName "ResourceGroupName"
start machine if it is stopped or deallocated

.DESCRIPTION

Start virtual machine in Azure. If it machine is stopped or deallocated, it will be started.

.PARAMETER VmName
Name of the virtual machine in Azure Subscription

.PARAMETER ResourceGroupName
Name of the resource group in Azure Subscription where VM is located

#>
[CmdletBinding(DefaultParameterSetName = "Azure")]
param(
    [Parameter(HelpMessage = "Provide the VM name", Mandatory = $true, ParameterSetName = "VM")]
    [string]    
    $VmName,
    [Parameter(HelpMessage = "Provide the resource group name", Mandatory = $true, ParameterSetName = "VM")]
    [string]    
    $ResourceGroupName
)

Write-Output "Getting VM $VmName in resource group $ResourceGroupName and status about Azure Virtual Machine"
$vmStatus = Get-AzVM -Name $VmName -ResourceGroupName $ResourceGroupName -Status
Write-Output "Status of VM $($vmStatus.Statuses[1].Code)"
$result = $vmStatus.Statuses[1].Code -eq "PowerState/running"
if ($result -eq $false) {
    Write-Verbose "Starting Azure VM"
    Start-AzVM -Name $VmName -ResourceGroupName $ResourceGroupName | Out-Null
}       

Write-Output "Machine $VmName in resource group $ResourceGroupName is running."