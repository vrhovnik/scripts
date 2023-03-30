<#
.SYNOPSIS

Get weather from wttr.in and show it in RSS

.EXAMPLE

PS > Get-WeatherInfo
get stats for weather for current location


#>

Invoke-WebRequest wttr.in | Select-Object -ExpandProperty Content