Function Export-ImagesFromWord {
    <#
.SYNOPSIS
Extracts images from a Word document and copies them to a new location

.DESCRIPTION
Extracts images from a Word document and copies them to a new location. 
After the extraction the caption informatino will be outputed to the screen.

The script is authored from Matthew Dowst - https://www.dowst.dev/about-me/

.PARAMETER DocumentPath
The path of the Word Document

.PARAMETER Destination
The folder to copy the file into

.EXAMPLE
Export-ImagesFromWord -DocumentPath "D:\scripts\ImageExamples.docx" -Destination "D:\scripts\images"

.NOTES
Does not require Word to be installed

.LINK
https://www.dowst.dev/extracting-images-from-word/

#>
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$DocumentPath,
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )

    # Create a temporary folder to hold the extracted files
    $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($documentPath) 
    $extractPath = Join-Path $env:Temp "mediaExtract\$($BaseName)"
    If (Test-Path $extractPath) {
        Remove-Item -Path $extractPath -Force -Recurse | Out-Null
    }
    New-Item -type directory -Path $extractPath | Out-Null

    # Copy the Word document as a zip and expand it
    $zipPath = Join-Path $extractPath "$($BaseName).zip"
    $zip = Copy-Item $documentPath $zipPath -Force -PassThru
    Expand-Archive -Path $zip.FullName -DestinationPath $extractPath -Force

    # Get the media files extracted and copy them to the output folder
    $mediaPath = Join-Path $extractPath 'word\media'
    If (-not(Test-Path $Destination)) {
        New-Item -type directory -Path $Destination | Out-Null
    }
    $extractedfigures = Get-ChildItem $mediaPath -File | Copy-Item -Destination $Destination -PassThru | Select-Object Name, @{l = 'Figure'; e = { $null } }, 
        @{l = 'Caption'; e = { '' } }, @{l = 'Id'; e = { [int]$($_.BaseName.Replace('image', '')) } }, FullName

    # Get the document configuration
    $documentXmlPath = Join-Path $extractPath 'word\document.xml'
    [xml]$docXml = Get-Content $documentXmlPath -Raw

    # Get all the paragraphs to find the images and captions
    $paragraphs = $docXml.document.body.p | Select-Object @{l = 'keepNext'; e = { @($_.pPr.ChildNodes.LocalName).Contains('keepNext') } }, 
        @{l = 'Id'; e = { $_.r.drawing.inline.docPr.id } }, @{l = 'CaptionId'; e = { $_.fldSimple.r.t } }, @{l = 'Prefix'; e = { $_.r[0].t.'#text' } }, 
        @{l = 'Text'; e = { $_.r[-1].t.'#text' } }, @{l = 'instr'; e = { $_.fldSimple.instr } }

    # Parse through each paragraph to match the caption to the image
    for ($i = 0; $i -lt $paragraphs.Count; $i++) {
        $capId = -1
        if ($paragraphs[$i].Id -gt 0 -and $paragraphs[$i].keepNext -eq $true) {
            $capId = $i + 1
        }
        elseif ($paragraphs[$i].Id -gt 0 -and $paragraphs[$i - 1].keepNext -eq $true) {
            $capId = $i - 1
        }

        if ($capId -gt -1) {
            $extractedfigures | Where-Object { $_.Id -eq $paragraphs[$i].Id } | ForEach-Object {
                $_.Figure = $paragraphs[$capId].CaptionId
                $_.Caption = "$($paragraphs[$capId].Prefix)$($paragraphs[$capId].CaptionId)$($paragraphs[$capId].Text)"
            }
        }
    }

    $extractedfigures | Select-Object Name, Figure, Caption, FullName
}