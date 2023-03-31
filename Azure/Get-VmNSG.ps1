<#

.SYNOPSIS

get NSG associated with VM and details of the NSG

.EXAMPLE

PS > GetVmNSG -VmName "VMName" -ResourceGroupName "ResourceGroupName"
get NSG from VM in resource group ResourceGroupName

.DESCRIPTION

get NSG associated with VM and details of the NSG

#>

param(
    [Parameter(HelpMessage = "Provide the VM name", Mandatory = $true)]
    [string]    
    $VmName,
    [Parameter(HelpMessage = "Provide the resource group name", Mandatory = $true)]
    [string]    
    $ResourceGroupName
)

Write-Information "Get VM $VmName in resource group $ResourceGroupName"
$vm = Get-AzVM -VMName $vmName -ResourceGroupName $rgName

Write-Verbose "VM $VmName in resource group $ResourceGroupName with id $($vm.Id)"
Write-Information "Get Network Interface Card associated with VM $VmName in resource group $ResourceGroupName"

$nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id

Write-Verbose "Getting NIC $($nic.Name) in resource group $($nic.ResourceGroupName) with id $($nic.Id)"
Write-Verbose "Calling finished, returned Name,location, ResourceGroupName, ProvisioningState, ResourceGuid"

Get-AzNetworkSecurityGroup | Where-Object -Property Id -EQ $nic.NetworkSecurityGroup[0].Id | 
Format-Table Name, Location, ResourceGroupName, ProvisioningState, ResourceGuid



