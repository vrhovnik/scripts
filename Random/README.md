# Random Scripts

Miscellaneous PowerShell scripts for everyday utility tasks.

## Prerequisites

- [PowerShell 7+](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- `Speak-Text.ps1` requires Windows with the `System.Speech` assembly (not available on Linux/macOS)

## Scripts

### `Get-WeatherInfo.ps1`

Fetches and displays the current weather for your location using the free [wttr.in](https://wttr.in) service.

```powershell
Get-WeatherInfo.ps1
```

The weather information is shown in a text-based format directly in the terminal. No API key is required — `wttr.in` automatically detects your location from your IP address.

Example output:
```
Weather report: Berlin, Germany

      \   /     Sunny
       .-.      +20(18) °C
    ― (   ) ―   ↗ 15 km/h
       `-'      10 km
      /   \     0.0 mm
```

📖 [wttr.in documentation](https://github.com/chubin/wttr.in)

---

### `Speak-Text.ps1`

Uses the .NET `System.Speech.Synthesis.SpeechSynthesizer` class to speak provided text aloud through your system's audio output.

> ⚠️ **Windows only** — requires the `System.Speech` assembly which is only available on Windows.

```powershell
Speak-Text -Text "Hello, World!"
Speak-Text -Text "The deployment has completed successfully."
```

📖 [System.Speech.Synthesis namespace](https://learn.microsoft.com/en-us/dotnet/api/system.speech.synthesis)

---

## Tests

Tests are in the [`tests/`](tests/) folder and use [Pester](https://pester.dev/).

```powershell
Invoke-Pester -Path ./tests/Random.Tests.ps1 -Output Detailed
```

Tests validate syntax, parameter definitions, help content, and script content patterns. Network calls are not made during tests.

## Additional Resources

- [wttr.in weather service](https://wttr.in)
- [PowerShell Invoke-WebRequest](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest)
- [.NET Speech Synthesis](https://learn.microsoft.com/en-us/dotnet/api/system.speech.synthesis)
