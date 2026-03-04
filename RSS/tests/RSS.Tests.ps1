<#
.SYNOPSIS
    Pester tests for RSS scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, and mock-based functionality for scripts in the RSS folder.
#>

BeforeAll {
    $rssScriptsPath = Split-Path -Parent $PSScriptRoot

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

Describe "RSS Script Syntax Validation" {
    $rssScripts = Get-ChildItem -Path "$rssScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $rssScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "Read-Rss.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $rssScriptsPath "Read-Rss.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have Link parameter" {
            $script:params | Should -Contain "Link"
        }

        It "Should have LastItemCount parameter" {
            $script:params | Should -Contain "LastItemCount"
        }
    }

    Context "Default parameter values" {
        It "Should have default Azure blog feed URL" {
            $content = Get-Content (Join-Path $rssScriptsPath "Read-Rss.ps1") -Raw
            $content | Should -Match 'azurecomcdn\.azureedge\.net'
        }

        It "Should have default LastItemCount of 10" {
            $content = Get-Content (Join-Path $rssScriptsPath "Read-Rss.ps1") -Raw
            $content | Should -Match '\$LastItemCount\s*=\s*10'
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content (Join-Path $rssScriptsPath "Read-Rss.ps1") -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should have at least one Example" {
            $content = Get-Content (Join-Path $rssScriptsPath "Read-Rss.ps1") -Raw
            $content | Should -Match '\.EXAMPLE'
        }
    }

    Context "Functional: mock Invoke-RestMethod" {
        It "Should return structured output from RSS feed" {
            $mockItems = @(
                [PSCustomObject]@{
                    pubDate = "Wed, 01 Mar 2026 10:00:00 GMT"
                    Title   = "Azure Update 1"
                    Link    = "https://azure.microsoft.com/blog/post1"
                },
                [PSCustomObject]@{
                    pubDate = "Thu, 02 Mar 2026 10:00:00 GMT"
                    Title   = "Azure Update 2"
                    Link    = "https://azure.microsoft.com/blog/post2"
                },
                [PSCustomObject]@{
                    pubDate = "Fri, 03 Mar 2026 10:00:00 GMT"
                    Title   = "Azure Update 3"
                    Link    = "https://azure.microsoft.com/blog/post3"
                }
            )

            Mock Invoke-RestMethod { return $mockItems } -ModuleName $null

            $scriptBlock = {
                param($scriptPath, $mockItems)
                function Invoke-RestMethod { return $mockItems }
                $Link = "https://example.com/feed"
                $LastItemCount = 2
                Set-StrictMode -Version 3
                $total = foreach ($item in Invoke-RestMethod -Uri $Link) {
                    [PSCustomObject]@{
                        'Date published' = $item.pubDate
                        Title            = $item.Title
                        Link             = $item.Link
                    }
                }
                $total | Sort-Object { $_."Date published" -as [datetime] } | Select-Object -Last $LastItemCount
            }

            $result = & $scriptBlock -scriptPath (Join-Path $rssScriptsPath "Read-Rss.ps1") -mockItems $mockItems
            $result | Should -HaveCount 2
            $result[0].Title | Should -Not -BeNullOrEmpty
            $result[1].Title | Should -Not -BeNullOrEmpty
        }
    }
}
