<#
.SYNOPSIS
    Pester tests for Random scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, and help content for all scripts in the Random folder.
#>

BeforeAll {
    $randomScriptsPath = Split-Path -Parent $PSScriptRoot

    function Get-ScriptAst {
        param([string]$ScriptPath)
        $errors = $null
        $tokens = $null
        $ast = [System.Management.Automation.Language.Parser]::ParseFile($ScriptPath, [ref]$tokens, [ref]$errors)
        return @{ Ast = $ast; Errors = $errors; Tokens = $tokens }
    }

    function Get-ScriptParameters {
        param([string]$ScriptPath)
        $result = Get-ScriptAst -ScriptPath $ScriptPath
        return $result.Ast.FindAll(
            { param($node) $node -is [System.Management.Automation.Language.ParameterAst] },
            $true
        ) | ForEach-Object { $_.Name.VariablePath.UserPath }
    }
}

Describe "Random Script Syntax Validation" {
    $randomScripts = Get-ChildItem -Path "$randomScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $randomScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "Get-WeatherInfo.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $randomScriptsPath "Get-WeatherInfo.ps1"
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should have at least one Example" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.EXAMPLE'
        }
    }

    Context "Script content" {
        It "Should call wttr.in for weather data" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match 'wttr\.in'
        }

        It "Should use Invoke-WebRequest" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match 'Invoke-WebRequest'
        }
    }
}

Describe "Speak-Text.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $randomScriptsPath "Speak-Text.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have Text parameter" {
            $script:params | Should -Contain "Text"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should have a Description" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.DESCRIPTION'
        }

        It "Should have at least one Example" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.EXAMPLE'
        }
    }

    Context "Script content" {
        It "Should use System.Speech assembly" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match 'System\.Speech'
        }

        It "Should use SpeechSynthesizer" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match 'SpeechSynthesizer'
        }
    }
}
