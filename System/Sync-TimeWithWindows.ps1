<#
    .SYNOPSIS
    This function synchronizes the system time with the Windows time service.

    # .DESCRIPTION
    The `Sync-TimeWithWindows` function retrieves the current time from the Windows time service and sets the system time accordingly.
    It uses the `w32tm` command to query the time and then updates the system clock.

    .EXAMPLE
    .\Sync-TimeWithWindows.ps1

#>

Write-Host "Synchronizing system time with Windows time service..."
try
{
    Write-Host "Checking Windows Time service status..."
    $service = Get-Service w32time
    if ($service.Status -ne 'Running') {
        Write-Host "Starting Windows Time service..."
        Start-Service w32time
    }
    Write-Host "Windows Time Service is running. Synchronizing time..."
    # Configure the time server to time.windows.net
    Write-Host "Configuring time server to time.windows.net..."
    w32tm /config /manualpeerlist:"time.windows.net" /syncfromflags:manual /reliable:yes /update

    # Resync the time
    Write-Host "Forcing time synchronization..."
    w32tm /resync /force

    # Display the current configuration
    Write-Host "Current time configuration:"
    w32tm /query /status
}
catch
{
    Write-Error "An error occurred while synchronizing time: $_"
}
