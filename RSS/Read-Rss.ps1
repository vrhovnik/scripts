<#

.SYNOPSIS

Read last specific number of RSS item feed and shows it in a terminal

.EXAMPLE

PS > ReadRss "https://azurecomcdn.azureedge.net/en-us/blog/feed/"
Get last 10 items from Azure Feed and shows them in terminal

PS > ReadRss "https://azurecomcdn.azureedge.net/en-us/blog/feed/" -LastItemCount 2
Get last 2 items from Azure Feed and shows them in terminal

#>
[CmdletBinding(DefaultParameterSetName = "RSS")]
[alias('rr')]
param(    
    [Parameter(Position=0)]
    $Link = "https://azurecomcdn.azureedge.net/en-us/blog/feed/",
	[Parameter(Position=1)]
	[int]$LastItemCount = 10
)

Set-StrictMode -Version 3

if ($Link -eq "") {
	$Link = "https://azurecomcdn.azureedge.net/en-us/blog/feed/"
}

$total = foreach ($item in Invoke-RestMethod -Uri $Link) {
    [PSCustomObject]@{
        'Date published'   = $item.pubDate
        Title              = $item.Title
        Link               = $item.Link
    }
}

$total | Sort-Object { $_."Date published" -as [datetime] } |  Select-Object -Last $LastItemCount