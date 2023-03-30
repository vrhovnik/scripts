<#

.SYNOPSIS

maximizes the window of the process

.EXAMPLE

PS > Max-Window -ProcessName "notepad"
finds notepad process and maximizes the window

.DESCRIPTION

Finds process and maximizes the window. If it doesn't run, it will exit. Also, if process is empty, it will exit.

Function Courtsy of: community.idera.com/database-tools/powershell/powertips/b/tips/posts/bringing-window-in-the-foreground

#>

param(
    [Parameter(HelpMessage = "Provide the name of the proces to put in front and maximize the window", Mandatory = $true)]
    [string]        
    $ProcessName
)


function Show-Process($Process, [Switch]$Maximize) {
    <# Function Courtsy of: community.idera.com/database-tools/powershell/powertips/b/tips/posts/bringing-window-in-the-foreground#>
    $sig = '
    [DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll")] public static extern int SetForegroundWindow(IntPtr hwnd);
  '
    if ($Maximize) { $Mode = 3 } else { $Mode = 4 }
    $type = Add-Type -MemberDefinition $sig -Name WindowAPI -PassThru
    $hwnd = $process.MainWindowHandle
    $null = $type::ShowWindowAsync($hwnd, $Mode)
    $null = $type::SetForegroundWindow($hwnd)
}

if ($ProcessName -eq "") {
    Write-Output "ProcessName is not defined, use Get-Location option."
    return;
}

if ((Get-process -name $ProcessName).Count -eq 0) {
    Write-Output  "ProcessName $ProcessName is not defined, check if it runs."
    return;
}

$procId = (Get-process -name $ProcessName | Select-Object -First 1).ID
Show-Process -Process (Get-Process -Id $procId) -Maximize