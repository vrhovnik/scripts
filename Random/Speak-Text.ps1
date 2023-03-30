<#

.SYNOPSIS

Speaks provided text

.EXAMPLE

PS > Speak-Text -Text "Hello World"
uses .NET library to speak provided text - in this case "Hello World"

.DESCRIPTION

It uses .NET library to speak provided text. It uses System.Speech.Synthesis.SpeechSynthesizer class and Speak method.

#>

param(
    [Parameter(HelpMessage = "Provide the root path which contains bin,obj folders", Mandatory = $true)]
    [string]    
    $Text    
)

Add-Type -AssemblyName System.Speech
$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
Write-Information "Speaking text: $Text"
$speak.Speak($Text)