# Office Scripts

PowerShell scripts for working with Microsoft Office documents.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- Microsoft Word is **not** required — the script works by treating `.docx` files as ZIP archives.

## Scripts

### `Export-ImagesFromWord.ps1`

Extracts all images embedded in a Word document (`.docx`) and copies them to a destination folder. Also outputs caption information from the document.

This script was originally authored by [Matthew Dowst](https://www.dowst.dev/extracting-images-from-word/).

```powershell
# Import the function
. .\Export-ImagesFromWord.ps1

# Extract images
Export-ImagesFromWord -DocumentPath "C:\docs\report.docx" -Destination "C:\docs\images"
```

The function returns objects with the following properties:

| Property   | Description                            |
|------------|----------------------------------------|
| `Name`     | File name of the extracted image       |
| `Figure`   | Figure number from the document        |
| `Caption`  | Full caption text                      |
| `FullName` | Full path to the extracted image file  |

#### How it works

1. The `.docx` file is copied as a `.zip` archive and extracted to a temp folder.
2. Images from the `word/media/` folder are copied to the destination.
3. The `word/document.xml` is parsed to match images with their captions.

📖 [Open XML format for Office documents](https://learn.microsoft.com/en-us/office/open-xml/open-xml-sdk)

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/Office.Tests.ps1 -Output Detailed
```

Tests validate script syntax, parameter definitions, function structure, and help content.

## Additional Resources

- [Office Open XML specification](https://learn.microsoft.com/en-us/office/open-xml/open-xml-sdk)
- [PowerShell and Word](https://learn.microsoft.com/en-us/powershell/scripting/overview)
