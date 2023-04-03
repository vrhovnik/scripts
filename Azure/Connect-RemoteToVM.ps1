<#

.SYNOPSIS

Connect via PS remote to VM in Azure

.EXAMPLE

PS > Connect-RemoteToVM -VmName "VMName" -ResourceGroupName "ResourceGroupName"
connect PS remotely on VM in Azure with name VMName in resource group ResourceGroupName

.EXAMPLE

PS > Connect-RemoteToVM -VmName "VMName" -ResourceGroupName "ResourceGroupName" -AutoStart
connect PS remotely on VM in Azure with name VMName in resource group ResourceGroupName and if not running it will run it

.DESCRIPTION

Connect via PS remotely to VM in Azure. It will get public ip and check if it works.


.PARAMETER VmName
Name of the virtual machine in Azure Subscription

.PARAMETER ResourceGroupName
Name of the resource group in Azure Subscription where VM is located

.PARAMETER AutoStart
$true to start machine if not running

#>
[CmdletBinding(DefaultParameterSetName = "Azure")]
param(
    [Parameter(HelpMessage = "Provide the VM name", Mandatory = $true, ParameterSetName = "VM")]
    [string]    
    $VmName,
    [Parameter(HelpMessage = "Provide the resource group name", Mandatory = $true, ParameterSetName = "VM")]
    [string]    
    $ResourceGroupName,
    [Parameter(HelpMessage = "Start machine if not running", Mandatory = $false)]
    [switch]$AutoStart
)

Write-Verbose "Checking trusted hosts on the client machine for the VM $VmName"
$trustedHosts = Get-Item wsman:\localhost\Client\TrustedHosts
if ($trustedHosts -eq "" -or $null -eq $trustedHosts -or $trustedHosts.Value.Contains($VmName) -eq $false) {
    Write-Output "Trusted hosts on the client machine are empty, adding $VmName to trusted hosts on the client machine"
    Set-Item wsman:\localhost\Client\TrustedHosts -Value $VmName -Confirm:$false
    Write-Output "Added $VmName to trusted hosts on the client machine, continuing with connecting remotely to $VmName"
}


Write-Output "Establishing remote connection to VM $VmName"
$Skip = New-PSSessionOption -SkipCACheck -SkipCNCheck
Write-Verbose "Skip the requirement to import a certificate to the VM when you start the session"

Write-Verbose "Getting IP to connect to the VM"
$vm = Get-AzVM -VMName $VmName -ResourceGroupName $ResourceGroupName
Write-Verbose "VM $VmName in resource group $ResourceGroupName with id $($vm.Id)"
$nic = Get-AzNetworkInterface -Name $vm.NetworkInterfaceIds[0]

if ($null -eq $nic.IpConfigurations.PublicIpAddress) {
    Write-Error "VM $VmName in resource group $ResourceGroupName does not have public IP address"
    return
}

if ($AutoStart) {
    $vmStatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status
    if ($vmStatus.Statuses[1].Code -ne "PowerState/running") {
        Write-Output "Machine $VmName is not running, starting it."
        Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Verbose
        Write-Output "Machine $VmName started."
    }
}

$publicIpName = $nic.IpConfigurations.PublicIpAddress.Name
Write-Verbose "Name of the public IP is $publicIpName"
$publicIp = Get-AzPublicIpAddress -Name $publicIpId
Write-Verbose "Public IP is $($publicIp.IpAddress) - connecting to it..."
Enter-PSSession -ComputerName $publicIp.IpAddress -port "5986" -Credential (Get-Credential) -useSSL -SessionOption $Skip