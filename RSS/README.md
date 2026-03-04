# RSS Scripts

PowerShell scripts for reading and displaying RSS feeds directly in the terminal.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- Internet access to the RSS feed URL

## Scripts

### `Read-Rss.ps1`

Alias: `rr`

Fetches the latest items from an RSS feed and displays them in the terminal as a table with publication date, title, and link.

```powershell
# Read last 10 items from the Azure blog (default)
Read-Rss.ps1

# Read last 5 items
Read-Rss.ps1 -LastItemCount 5

# Read from a custom feed
Read-Rss.ps1 -Link "https://devblogs.microsoft.com/powershell/feed/" -LastItemCount 3
```

Output example:

```
Date published             Title                           Link
--------------             -----                           ----
Thu, 01 Feb 2024 10:00:00  Announcing PowerShell 7.5       https://devblogs.microsoft.com/...
Fri, 09 Feb 2024 10:00:00  New Azure Features in February  https://azure.microsoft.com/...
```

#### Parameters

| Parameter       | Type    | Default                                         | Description                          |
|-----------------|---------|-------------------------------------------------|--------------------------------------|
| `Link`          | string  | Azure blog feed URL                             | URL of the RSS/Atom feed             |
| `LastItemCount` | int     | `10`                                            | Number of most recent items to show  |

#### Popular RSS Feed URLs

| Source                    | URL                                                                    |
|---------------------------|------------------------------------------------------------------------|
| Azure Updates             | `https://azurecomcdn.azureedge.net/en-us/blog/feed/`                   |
| Azure Blog                | `https://azure.microsoft.com/en-us/blog/feed/`                         |
| PowerShell Blog           | `https://devblogs.microsoft.com/powershell/feed/`                      |
| .NET Blog                 | `https://devblogs.microsoft.com/dotnet/feed/`                          |
| Microsoft Tech Community  | `https://techcommunity.microsoft.com/t5/s/gxcuf89792/rss/board?board.id=AzureBlog` |

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/RSS.Tests.ps1 -Output Detailed
```

Tests include syntax validation, parameter checks, default value verification, and a mock-based functional test that validates output structure without making network calls.

## Additional Resources

- [PowerShell Invoke-RestMethod](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-restmethod)
- [RSS 2.0 specification](https://www.rssboard.org/rss-specification)
