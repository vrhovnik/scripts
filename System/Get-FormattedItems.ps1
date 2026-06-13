[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string]$Path = ".",

    [Parameter()]
    [switch]$Recurse
)

function Get-FormattedItems {
    <#
    .SYNOPSIS
        Lists folders and files in a nicely formatted way with color coding.
    
    .DESCRIPTION
        Displays directories and files with visual distinction, sizes, and modification dates.
        Folders are shown in cyan, files in white, with human-readable sizes.
    
    .PARAMETER Path
        The path to list items from. Defaults to current directory.
    
    .PARAMETER Recurse
        Include subdirectories recursively.
    
    .EXAMPLE
        Get-FormattedItems
        Lists items in current directory
    
    .EXAMPLE
        Get-FormattedItems -Path "C:\Projects" -Recurse
        Lists all items in C:\Projects recursively
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Position = 0)]
        [string]$Path = ".",
        
        [Parameter()]
        [switch]$Recurse
    )
    
    # Helper function to convert bytes to human-readable format
    function ConvertTo-HumanReadableSize {
        param([long]$Bytes)
        
        if ($Bytes -eq 0) { return "0 B" }
        
        $sizes = @("B", "KB", "MB", "GB", "TB")
        $index = 0
        $size = [double]$Bytes
        
        while ($size -ge 1024 -and $index -lt ($sizes.Count - 1)) {
            $size = $size / 1024
            $index++
        }
        
        return "{0:N2} {1}" -f $size, $sizes[$index]
    }
    
    # Get items
    $items = if ($Recurse) {
        Get-ChildItem -Path $Path -Recurse -Force
    } else {
        Get-ChildItem -Path $Path -Force
    }
    
    # Separate folders and files
    $folders = $items | Where-Object { $_.PSIsContainer }
    $files = $items | Where-Object { -not $_.PSIsContainer }
    
    # Display header
    Write-Host "`n" -NoNewline
    Write-Host "Directory: " -ForegroundColor Gray -NoNewline
    Write-Host (Resolve-Path $Path).Path -ForegroundColor Yellow
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    Write-Host ""
    
    # Display folders
    if ($folders.Count -gt 0) {
        Write-Host "FOLDERS:" -ForegroundColor Green
        Write-Host ""
        
        foreach ($folder in $folders) {
            $lastWrite = $folder.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            $indent = if ($Recurse) { 
                $depth = ($folder.FullName.Replace((Resolve-Path $Path).Path, "").Split([IO.Path]::DirectorySeparatorChar).Count - 1)
                "  " * $depth
            } else { "" }
            
            Write-Host "$indent" -NoNewline
            Write-Host "[DIR]  " -ForegroundColor Cyan -NoNewline
            Write-Host "$lastWrite  " -ForegroundColor DarkGray -NoNewline
            Write-Host $folder.Name -ForegroundColor Cyan
        }
        
        Write-Host ""
    }
    
    # Display files
    if ($files.Count -gt 0) {
        Write-Host "FILES:" -ForegroundColor Green
        Write-Host ""
        
        foreach ($file in $files) {
            $size = ConvertTo-HumanReadableSize -Bytes $file.Length
            $lastWrite = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
            $indent = if ($Recurse) { 
                $depth = ($file.FullName.Replace((Resolve-Path $Path).Path, "").Split([IO.Path]::DirectorySeparatorChar).Count - 1)
                "  " * $depth
            } else { "" }
            
            Write-Host "$indent" -NoNewline
            Write-Host "[FILE] " -ForegroundColor White -NoNewline
            Write-Host "$lastWrite  " -ForegroundColor DarkGray -NoNewline
            Write-Host ("{0,-12}" -f $size) -ForegroundColor Yellow -NoNewline
            Write-Host " $($file.Name)" -ForegroundColor White
        }
        
        Write-Host ""
    }
    
    # Display summary
    Write-Host ("-" * 80) -ForegroundColor DarkGray
    Write-Host "Total: " -ForegroundColor Gray -NoNewline
    Write-Host "$($folders.Count) " -ForegroundColor Cyan -NoNewline
    Write-Host "folders, " -ForegroundColor Gray -NoNewline
    Write-Host "$($files.Count) " -ForegroundColor White -NoNewline
    Write-Host "files" -ForegroundColor Gray
    
    if ($files.Count -gt 0) {
        $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
        Write-Host "Total size: " -ForegroundColor Gray -NoNewline
        Write-Host (ConvertTo-HumanReadableSize -Bytes $totalSize) -ForegroundColor Yellow
    }
    
    Write-Host ""
}

# Create an alias for convenience
Set-Alias -Name lsf -Value Get-FormattedItems -Description "List files and folders formatted"

if ($MyInvocation.InvocationName -ne '.') {
    Get-FormattedItems -Path $Path -Recurse:$Recurse
}
