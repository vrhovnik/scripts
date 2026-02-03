<#

.SYNOPSIS

Read pdf and docx files in a folder and its subfolders to get page counts.

.EXAMPLE

PS > Count-FilePages -Folder "c:\docs" -pdinfoPath "C:\Program Files\xpdf\bin64\pdfinfo.exe"
Read all PDF and DOCX files in the c:\docs folder and its subfolders to get page counts, using the specified path to pdfinfo.exe.

.DESCRIPTION

Scripts which uses pdfinfo to read page counts from PDF and DOCX files in a folder and its subfolders.
It uses pdfinfo - more on https://www.xpdfreader.com/download.html

#>
[CmdletBinding(DefaultParameterSetName = "System")]
[Alias('count-filepages')]
param(   
       [Parameter(Position = 0)]
       [String]$Folder,
       [Parameter(Position = 1)]
       [String]$PdfInfoPath
)

Write-Host "Starting with reading files"
if (-not $Folder) {
    $Folder = Read-Host "Enter folder path to scan for PDF and DOCX files"
}
if (-not $PdfInfoPath) {
    $PdfInfoPath = Read-Host "Enter full path to pdfinfo.exe"
}
function Get-PdfPageCount {
    param([string]$path)
    # extracts the numeric value after "Pages:"
    $pages = (& $PdfInfoPath $path | Select-String -Pattern '(?<=Pages:\s*)\d+').Matches.Value
    if ([string]::IsNullOrWhiteSpace($pages)) { return $null }
    return [int]$pages
}

# --- DOCX page count helper using Shell.Application metadata ---
function Get-DocxPageCount {
    param([string]$path)

    $shell = New-Object -ComObject "Shell.Application"
    $dir   = Split-Path $path
    $name  = Split-Path $path -Leaf

    $ns    = $shell.Namespace($dir)
    $item  = $ns.ParseName($name)

    # Standard Windows property exposed in Details tab
    $pc = $item.ExtendedProperty("System.Document.PageCount")
    if ($pc -eq $null -or $pc -eq "") { return $null }
    return [int]$pc
}

$results = @()

Get-ChildItem -Path $Folder -File -Recurse |
Where-Object { $_.Extension -in ".pdf", ".docx" } |
ForEach-Object {
    $pages = $null
    try {
        if ($_.Extension -eq ".pdf")  { $pages = Get-PdfPageCount  $_.FullName }
        if ($_.Extension -eq ".docx") { $pages = Get-DocxPageCount $_.FullName }
    } catch {
        $pages = $null
    }

    $results += [pscustomobject]@{
        FileName  = $_.Name
        FullPath  = $_.FullName
        Extension = $_.Extension
        Pages     = $pages
    }
}

# Export per-file page counts
$outCsv = Join-Path $Folder "page-counts.csv"
$results | Export-Csv -NoTypeInformation -Path $outCsv

# Show totals (ignores files where page count couldn't be read)
$totalPages = ($results | Where-Object Pages | Measure-Object Pages -Sum).Sum
$totalFiles = $results.Count

"Files scanned: $totalFiles"
"Total pages (where readable): $totalPages"
"CSV written to: $outCsv"

Write-Host "Showing data in CSV:"
$csv = Import-Csv $outCsv
$total = ($csv | Measure-Object -Property Pages -Sum).Sum
# Add a summary row
$csv += [pscustomobject]@{
    FileName = "TOTAL"
    Pages    = $total
}

$totalPages = ($csv | Measure-Object -Property Pages -Sum).Sum
$totalFiles = $csv.Count

Write-Host "=============================="
Write-Host "Files processed : $totalFiles"
Write-Host "Total pages     : $totalPages"
Write-Host "=============================="

$csv | Export-Csv $outCsv -NoTypeInformation

Write-Host "Done!"