# Azure Scripts

PowerShell scripts to help with common Microsoft Azure tasks. These scripts require the [Azure PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps) and/or the [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation).

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- [Azure PowerShell module](https://learn.microsoft.com/en-us/powershell/azure/install-az-ps)

```powershell
Install-Module -Name Az -Scope CurrentUser -Force
Connect-AzAccount
```

For scripts using Microsoft Graph:

```powershell
Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
```

## Scripts

### `Connect-RemoteToVM.ps1`

Connects via PowerShell Remoting to an Azure Virtual Machine.

```powershell
# Basic remote connection
Connect-RemoteToVM -VmName "MyVM" -ResourceGroupName "MyRG"

# Auto-start the VM if it is stopped
Connect-RemoteToVM -VmName "MyVM" -ResourceGroupName "MyRG" -AutoStart
```

📖 [PowerShell Remoting documentation](https://learn.microsoft.com/en-us/powershell/scripting/learn/remoting/running-remote-commands)

---

### `Create-AzureAdApplication.ps1`

Interactively creates an Azure AD application registration inside an Azure AD tenant.

```powershell
Create-AzureAdApplication.ps1 -tenantId "<your-tenant-id>"
```

📖 [Azure AD App Registration](https://learn.microsoft.com/en-us/azure/active-directory/develop/quickstart-register-app)

---

### `Enable-PSRemote.ps1`

Enables PowerShell Remoting on an Azure Virtual Machine. Adds the required NSG rule (port 5986), adds the VM to Trusted Hosts, and optionally establishes the remote session.

```powershell
# Enable PS Remote only
Enable-PSRemote -VmName "MyVM" -ResourceGroupName "MyRG"

# Enable and connect immediately
Enable-PSRemote -VmName "MyVM" -ResourceGroupName "MyRG" -EstablishRemoteConnection
```

📖 [Azure VM Run Command](https://learn.microsoft.com/en-us/azure/virtual-machines/run-command-overview)

---

### `Get-Admins.ps1`

Lists all Service Administrators, Co-Administrators, Owners, and Contributors of the currently signed-in Azure subscription.

```powershell
Get-Admins.ps1
```

📖 [Azure RBAC](https://learn.microsoft.com/en-us/azure/role-based-access-control/overview)

---

### `Get-AppInsightsTypes.ps1`

Identifies Application Insights resources by ingestion type (Classic vs. Workspace-based) in a given subscription.

```powershell
Get-AppInsightsTypes -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

📖 [Application Insights overview](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)

---

### `Get-AppSecurityKeyExpiration.ps1`

Checks for Azure AD application registrations with secrets or certificates expiring within a given number of days.

```powershell
# Check expiring in next 30 days (default)
Get-AppSecurityKeyExpiration

# Check expiring in next 7 days
Get-AppSecurityKeyExpiration -NumberOfDays 7

# Auto-install Microsoft.Graph module if missing
Get-AppSecurityKeyExpiration -NumberOfDays 7 -InstallDependency
```

📖 [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation)

---

### `Get-IpAddressesFromServiceTag.ps1`

Returns the IP address ranges for a specific Azure service tag in a given region.

```powershell
# Default: Azure Container Registry in West Europe
Get-IpAddressesFromServiceTag

# Custom region and service
Get-IpAddressesFromServiceTag -RegionName "EastUS" -ServiceName "AzureStorage"
```

📖 [Azure service tags](https://learn.microsoft.com/en-us/azure/virtual-network/service-tags-overview)

---

### `Get-VmNSG.ps1`

Retrieves the Network Security Group (NSG) associated with a Virtual Machine.

```powershell
Get-VmNSG -VmName "MyVM" -ResourceGroupName "MyRG"
```

📖 [Azure Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)

---

### `Install-AZCLI.ps1`

Downloads and installs the Azure CLI on a Windows machine.

```powershell
Install-AZCLI.ps1
```

📖 [Install Azure CLI on Windows](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows)

---

### `Send-Email.ps1`

Sends an email via Microsoft Graph from the currently signed-in user.

```powershell
Send-Email -ToUser "recipient@example.com" -Subject "Hello" -Body "<p>Test body</p>"

# Auto-install Microsoft.Graph module if missing
Send-Email -ToUser "recipient@example.com" -Subject "Hello" -Body "Body" -InstallDependency
```

📖 [Send mail via Microsoft Graph](https://learn.microsoft.com/en-us/graph/api/user-sendmail)

---

### `Set-ApplicationInsightRetention.ps1`

Changes the data retention period for an Application Insights resource.

```powershell
Set-ApplicationInsightRetention `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -ResourceGroupName "my-rg" `
    -Name "my-appinsights" `
    -RetentionInDays 90
```

📖 [Set data retention in Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/powershell#set-data-retention-by-using-a-powershell-script)

---

### `Start-Machine.ps1`

Starts a stopped or deallocated Azure Virtual Machine.

```powershell
Start-Machine -VmName "MyVM" -ResourceGroupName "MyRG"
```

📖 [Start an Azure VM with PowerShell](https://learn.microsoft.com/en-us/azure/virtual-machines/windows/tutorial-manage-vm)

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/Azure.Tests.ps1 -Output Detailed
```

Tests validate script syntax, parameter definitions, and help content without requiring an active Azure subscription.

## Additional Resources

- [Azure PowerShell documentation](https://learn.microsoft.com/en-us/powershell/azure/)
- [Azure CLI documentation](https://learn.microsoft.com/en-us/cli/azure/)
- [Microsoft Graph PowerShell SDK](https://learn.microsoft.com/en-us/powershell/microsoftgraph/overview)
- [Azure portal](https://portal.azure.com)
