<#

.SYNOPSIS

Enable PS remote on VM in Azure

.EXAMPLE

PS > Enable-PSRemote -VmName "VMName" -ResourceGroupName "ResourceGroupName"
enable PS remote on VM in Azure with name VMName in resource group ResourceGroupName

.EXAMPLE

PS > Enable-PSRemote -VmName "VMName" -ResourceGroupName "ResourceGroupName" -EstablishRemoteConnection
enable PS remote on VM in Azure with name VMName in resource group ResourceGroupName and establish remote connection to VM

.DESCRIPTION

Enable PS remote on VM in Azure. 
It adds rule to NSG to allow WinRM connections on port 5986, adds VM to trusted hosts on the client machine, 
enables PS remote on VM and adds rule to firewall to allow WinRM connections on the Virtual Machine via Run 
command on Azure VM and saves everything in transcript file.

.PARAMETER VmName
Name of the virtual machine in Azure Subscription

.PARAMETER ResourceGroupName
Name of the resource group in Azure Subscription where VM is located

.PARAMETER EstablishRemoteConnection
$true to establish remote connection to VM after enabling PS remote on VM

#>
[CmdletBinding(DefaultParameterSetName = "Azure")]
param(
    [Parameter(HelpMessage = "Provide the VM name", Mandatory = $true, ParameterSetName = "VM")]
    [string]    
    $VmName,
    [Parameter(HelpMessage = "Provide the resource group name", Mandatory = $true, ParameterSetName = "VM")]
    [string]    
    $ResourceGroupName,
    [Parameter(HelpMessage = "Establish remote connection to VM after enabling PS remote on VM", Mandatory = $false)]
    [switch]$EstablishRemoteConnection
)

Start-Transcript -Path "Enable-PSRemote.log" -Force

Write-Output "Getting VM $VmName in resource group $ResourceGroupName and all the details"

$vm = Get-AzVM -VMName $VmName -ResourceGroupName $ResourceGroupName
Write-Verbose "VM $VmName in resource group $ResourceGroupName with id $($vm.Id)"
$nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
Write-Verbose "Getting NIC $($nic.Name) in resource group $($nic.ResourceGroupName) with id $($nic.Id)"
$nsg = Get-AzNetworkSecurityGroup | Where-Object -Property Id -EQ $nic.NetworkSecurityGroup[0].Id 
Write-Verbose "Getting NSG $($nsg.Name) in resource group $($nsg.ResourceGroupName) with id $($nsg.Id)"

Write-Output "Adding network security rule to NSG $($nsg.Name) in resource group $($nsg.ResourceGroupName) to allow WinRM connections on port 5986"
Add-AzNetworkSecurityRuleConfig -Name WinRM -NetworkSecurityGroup $networkSecurityGroup `
    -Description "Allow WinRM" -Access Allow -Protocol Tcp -Direction Inbound -Priority 400 `
    -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 5986
Set-AzNetworkSecurityGroup -NetworkSecurityGroup $networkSecurityGroup
Write-Output "NSG rule added - changes applied."

Write-Output "Adding $VmName to trusted hosts on the client machine"
Set-Item wsman:\localhost\Client\TrustedHosts -value $VmName
Write-Output "Added $VmName to trusted hosts on the client machine, continuing with enabling PS remote on $VmName"

# Enable PS remote on VM
Write-Output "Adding rule to firewall to allow WinRM connections on the Virtual Machine via Run command on Azure VM $VmName"
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $VmName -CommandId 'RunPowerShellScript' -ScriptString 'Enable-PSRemoting -Force
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $command'
Write-Output "PS remote enabled on VM $VmName"

Stop-Transcript

if ($EstablishRemoteConnection) {
    Write-Output "Establishing remote connection to VM $VmName"
    $Skip = New-PSSessionOption -SkipCACheck -SkipCNCheck
    Write-Verbose "Skip the requirement to import a certificate to the VM when you start the session"
    Enter-PSSession -ComputerName  $VmName -port "5986" -Credential (Get-Credential) -useSSL -SessionOption $Skip
}