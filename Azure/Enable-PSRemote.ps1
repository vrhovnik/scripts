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
command on Azure VM and saves everything in transcript file. If -EstablishRemoteConnection is provided,
then it will get public IP of the VM and establish remote connection to it.

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

Start-Transcript -Path "Enable-PSRemote.log" -Append -Force

Write-Output "Getting VM $VmName in resource group $ResourceGroupName and all the details"

$vm = Get-AzVM -VMName $VmName -ResourceGroupName $ResourceGroupName
Write-Verbose "VM $VmName in resource group $ResourceGroupName with id $($vm.Id)"
$nic = Get-AzNetworkInterface -ResourceId $vm.NetworkProfile.NetworkInterfaces[0].Id
Write-Verbose "Getting NIC $($nic.Name) in resource group $($nic.ResourceGroupName) with id $($nic.Id)"
$nsg = Get-AzNetworkSecurityGroup | Where-Object -Property Id -EQ $nic.NetworkSecurityGroup[0].Id 
Write-Verbose "Getting NSG $($nsg.Name) in resource group $($nsg.ResourceGroupName) with id $($nsg.Id)"

#check, if NSG rule already exists
$rule = $nsg.SecurityRules | Where-Object -Property DestinationPortRange -EQ "5986"
if ($null -eq $rule) {
    Write-Output "Adding network security rule to NSG $($nsg.Name) in resource group $($nsg.ResourceGroupName) to allow WinRM connections on port 5986"
    Add-AzNetworkSecurityRuleConfig -Name "WinRM-$VmName" -NetworkSecurityGroup $nsg `
        -Description "Allow WinRM on $VmName" -Access Allow -Protocol Tcp -Direction Inbound -Priority 400 `
        -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 5986
    Set-AzNetworkSecurityGroup -NetworkSecurityGroup $nsg
    Write-Output "NSG rule added - changes applied."   
}

Write-Verbose "Checking trusted hosts on the client machine for the VM $VmName"
$trustedHosts = Get-Item wsman:\localhost\Client\TrustedHosts
if ($trustedHosts -eq "" -or $null -eq $trustedHosts -or $trustedHosts.Value.Contains($VmName) -eq $false) {
    Write-Output "Trusted hosts on the client machine are empty, adding $VmName to trusted hosts on the client machine"
    Set-Item wsman:\localhost\Client\TrustedHosts -Value $VmName
    Write-Output "Added $VmName to trusted hosts on the client machine, continuing with enabling PS remote on $VmName"
}

# Enable PS remote on VM
Write-Output "Adding rule to firewall to allow WinRM connections on the Virtual Machine via Run command on Azure VM $VmName"

Write-Verbose "Check, if machine is running. If not, start it."
$vmStatus = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Status
if ($vmStatus.Statuses[1].Code -ne "PowerState/running") {
    Write-Output "Machine $VmName is not running, starting it."
    Start-AzVM -ResourceGroupName $ResourceGroupName -Name $VmName -Verbose
    Write-Output "Machine $VmName started."
}

Write-Verbose "Machine $VmName is running, enabling PS remote on it."
Invoke-AzVMRunCommand -ResourceGroupName $ResourceGroupName -Name $VmName -CommandId 'RunPowerShellScript' -ScriptString 'Enable-PSRemoting -Force
New-NetFirewallRule -Name "Allow WinRM HTTPS" -DisplayName "WinRM HTTPS" -Enabled True -Profile Any -Action Allow -Direction Inbound -LocalPort 5986 -Protocol TCP
$thumbprint = (New-SelfSignedCertificate -DnsName $env:COMPUTERNAME -CertStoreLocation Cert:\LocalMachine\My).Thumbprint
$command = "winrm create winrm/config/Listener?Address=*+Transport=HTTPS @{Hostname=""$env:computername""; CertificateThumbprint=""$thumbprint""}"
cmd.exe /C $command'
Write-Output "PS remote enabled on VM $VmName"

Stop-Transcript

if ($EstablishRemoteConnection) {
    Write-Output "Establishing remote connection to VM $VmName"
    if ($null -eq $nic.IpConfigurations.PublicIpAddress) {
        Write-Error "VM $VmName in resource group $ResourceGroupName does not have public IP address"
        return
    }
    
    $Skip = New-PSSessionOption -SkipCACheck -SkipCNCheck
    Write-Verbose "Skip the requirement to import a certificate to the VM when you start the session"
    Write-Verbose "Getting IP to connect to the VM"
    $publicIpName = $nic.IpConfigurations.PublicIpAddress.Name
    Write-Verbose "Name of the public IP is $publicIpName"
    $publicIp = Get-AzPublicIpAddress -Name $publicIpId
    Write-Verbose "Public IP is $($publicIp.IpAddress)"
    Enter-PSSession -ComputerName $publicIp.IpAddress -port "5986" -Credential (Get-Credential) -useSSL -SessionOption $Skip
}