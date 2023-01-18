$total = foreach ($item in Invoke-RestMethod -Uri "https://azurecomcdn.azureedge.net/en-us/blog/feed/" ) {
    [PSCustomObject]@{
        'Date published'   = $item.pubDate
        Title              = $item.Title
        Link               = $item.Link
    }
}

$total | Sort-Object { $_."Date published" -as [datetime] } |  Select-Object -Last 10