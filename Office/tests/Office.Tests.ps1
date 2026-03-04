<#
.SYNOPSIS
    Pester tests for Office scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, and help content for all scripts in the Office folder.
#>

BeforeAll {
    $officeScriptsPath = Split-Path -Parent $PSScriptRoot

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

Describe "Office Script Syntax Validation" {
    $officeScripts = Get-ChildItem -Path "$officeScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $officeScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "Export-ImagesFromWord.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $officeScriptsPath "Export-ImagesFromWord.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have DocumentPath parameter" {
            $script:params | Should -Contain "DocumentPath"
        }

        It "Should have Destination parameter" {
            $script:params | Should -Contain "Destination"
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

        It "Should have a Link section" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.LINK'
        }
    }

    Context "Function definition" {
        It "Should define a function named Export-ImagesFromWord" {
            $scriptPath = Join-Path $officeScriptsPath "Export-ImagesFromWord.ps1"
            $result = Get-ScriptAst -ScriptPath $scriptPath
            $functionDef = $result.Ast.Find(
                { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Export-ImagesFromWord' },
                $true
            )
            $functionDef | Should -Not -BeNullOrEmpty
        }

        It "Should have CmdletBinding attribute" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\[CmdletBinding\(\)\]'
        }
    }
}
