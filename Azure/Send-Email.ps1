<#

.SYNOPSIS

Send email via Microsoft Graph from current signed in user

.EXAMPLE

PS > Send-Email -ToUser "info@info.com" -Subject "Test" -Body "Test body"
send email to the user info@info.com from current signed user in  MS Graph with subject Test and body Test body and save copy to Sent Items


.DESCRIPTION

Send email via Microsoft Graph. If FromUser is not defined it get's the user from the context and uses the email from that user.

 You will need to have MS Graph Module installed 
 https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0

 If you don't have the module installed, you will get 

.PARAMETER ToUser
user email to sent email to

.PARAMETER Subject
subject of the email

.PARAMETER Body
body of the email

.PARAMETER InstallDependency
$true install Ms Graph module, $false outputs instructions and finishes the script

.LINK
https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation?view=graph-powershell-1.0

#>
[CmdletBinding(DefaultParameterSetName = "MSGraph")]
param(    
    [Parameter(HelpMessage = "Provide the email to send to", Mandatory = $true)]
    [string]    
    $ToUser, 
    [Parameter(HelpMessage = "Provide the subject of email", Mandatory = $true)]
    [string]    
    $Subject, 
    [Parameter(HelpMessage = "Provide the body of email", Mandatory = $true)]
    [string]    
    $Body, 
    [Parameter(HelpMessage = "Install module automatically", Mandatory = $false)]
    [switch]$InstallDependency
)

Write-Verbose "Checking if Microsoft.Graph module is installed"
$moduleInstalled = Get-InstalledModule -Name "Microsoft.Graph"
if ($null -eq $moduleInstalled) {
    Write-Host "Microsoft.Graph module is not installed."
    if ($InstallDependency) {
        Install-Module -Name "Microsoft.Graph" -Force
        Import-Module Microsoft.Graph
        Write-Host "Module installed, continuing with execution."
    }
    else {
        Write-Host "Module is not installed, please install it manually."
        Write-Host "You can install it by running the following command:"
        Write-Host "Install-Module -Name 'Microsoft.Graph' -Force"
        Write-Host "Exiting..."
        return
    }
}

Write-Output "Connecting to Microsoft Graph with send scope on applications and read scope on user"
Connect-MgGraph -Scopes "Mail.Send", "User.Read.All"

Write-Verbose "Connected to MS graph, sending email with $FromUser"
$Message = @{
    ToRecipients = @(
        @{
            EmailAddress = @{
                Address = $ToUser
            }
        }
    )
    Subject = $Subject
    Body    = @{
        ContentType = "HTML";
        Content     = $Body
    }
}
    
Write-Verbose "Sending email to $ToUser with subject $Subject and body $Body"
Send-MgUserMail -Message $Message -SaveToSentItems
Write-Output "Email to $ToUser with subject $Subject has been sent."
