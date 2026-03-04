<#
.SYNOPSIS
    Pester tests for Containers scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, and business logic for all scripts in the Containers folder.
#>

BeforeAll {
    $containersScriptsPath = Split-Path -Parent $PSScriptRoot

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

    # Extract and define Test-SqlPasswordPolicy from New-Database.ps1 for isolated testing
    $newDatabasePath = Join-Path $containersScriptsPath "New-Database.ps1"
    $scriptContent = Get-Content $newDatabasePath -Raw
    $ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$null, [ref]$null)
    $functionDef = $ast.Find(
        { param($node) $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq 'Test-SqlPasswordPolicy' },
        $true
    )
    if ($functionDef) {
        Invoke-Expression $functionDef.Extent.Text
    }
}

Describe "Containers Script Syntax Validation" {
    $containersScripts = Get-ChildItem -Path "$containersScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $containersScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "New-Database.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $containersScriptsPath "New-Database.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have DatabaseName parameter" {
            $script:params | Should -Contain "DatabaseName"
        }

        It "Should have SaPwd parameter" {
            $script:params | Should -Contain "SaPwd"
        }

        It "Should have HostPort parameter" {
            $script:params | Should -Contain "HostPort"
        }

        It "Should have InstanceName parameter" {
            $script:params | Should -Contain "InstanceName"
        }

        It "Should have Overwrite parameter" {
            $script:params | Should -Contain "Overwrite"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content (Join-Path $containersScriptsPath "New-Database.ps1") -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should have at least one Example" {
            $content = Get-Content (Join-Path $containersScriptsPath "New-Database.ps1") -Raw
            $content | Should -Match '\.EXAMPLE'
        }
    }
}

Describe "Test-SqlPasswordPolicy function" {
    Context "Password length validation" {
        It "Should reject passwords shorter than 8 characters" {
            $result = Test-SqlPasswordPolicy -currentPwd "Abc1!"
            ($result -contains $false -or $result[-1] -eq $false) | Should -Be $true
        }

        It "Should reject an empty password" {
            $result = Test-SqlPasswordPolicy -currentPwd ""
            ($result -contains $false -or $result[-1] -eq $false) | Should -Be $true
        }
    }

    Context "Password complexity validation" {
        It "Should reject a password with only lowercase letters" {
            $result = Test-SqlPasswordPolicy -currentPwd "alllowercase"
            ($result -contains $false -or $result[-1] -eq $false) | Should -Be $true
        }

        It "Should reject a password with only uppercase letters" {
            $result = Test-SqlPasswordPolicy -currentPwd "ALLUPPERCASE"
            ($result -contains $false -or $result[-1] -eq $false) | Should -Be $true
        }

        It "Should accept a password with uppercase, lowercase and digit" {
            $result = Test-SqlPasswordPolicy -currentPwd "MyPassword1"
            ($result -contains $true -or $result[-1] -eq $true) | Should -Be $true
        }

        It "Should accept a password with uppercase, lowercase, digit and symbol" {
            $result = Test-SqlPasswordPolicy -currentPwd "MyP@ssw0rd!"
            ($result -contains $true -or $result[-1] -eq $true) | Should -Be $true
        }

        It "Should accept a password with lowercase, digit and symbol" {
            $result = Test-SqlPasswordPolicy -currentPwd "mypassword1!"
            ($result -contains $true -or $result[-1] -eq $true) | Should -Be $true
        }
    }

    Context "Password length boundary tests" {
        It "Should accept a password that is exactly 8 characters with mixed complexity" {
            $result = Test-SqlPasswordPolicy -currentPwd "MyP@ss1!"
            ($result -contains $true -or $result[-1] -eq $true) | Should -Be $true
        }

        It "Should accept a password of 128 characters" {
            $longPwd = "A1!" + ("a" * 125)
            $result = Test-SqlPasswordPolicy -currentPwd $longPwd
            ($result -contains $true -or $result[-1] -eq $true) | Should -Be $true
        }

        It "Should reject a password of 129 characters" {
            $tooLongPwd = "A1!" + ("a" * 126)
            $result = Test-SqlPasswordPolicy -currentPwd $tooLongPwd
            ($result -contains $false -or $result[-1] -eq $false) | Should -Be $true
        }
    }
}
