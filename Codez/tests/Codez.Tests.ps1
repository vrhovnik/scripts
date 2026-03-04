<#
.SYNOPSIS
    Pester tests for Codez scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, and help content for all scripts in the Codez folder.
#>

BeforeAll {
    $codezScriptsPath = Split-Path -Parent $PSScriptRoot

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

Describe "Codez Script Syntax Validation" {
    $codezScripts = Get-ChildItem -Path "$codezScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $codezScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "Remove-ObjBin.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $codezScriptsPath "Remove-ObjBin.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have Path parameter" {
            $script:params | Should -Contain "Path"
        }

        It "Should have RestartCurrentSession parameter" {
            $script:params | Should -Contain "RestartCurrentSession"
        }
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

    Context "Functional: bin and obj folder removal" {
        BeforeAll {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $script:testRoot = Join-Path $tmpPath "pester-test-$(New-Guid)"
            New-Item -ItemType Directory -Path $script:testRoot | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testRoot "project1" "bin") -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testRoot "project1" "obj") -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testRoot "project2" "bin") -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testRoot "project1" "bin" "app.dll") -Force | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testRoot "project1" "obj" "app.pdb") -Force | Out-Null
        }

        AfterAll {
            if ($script:testRoot -and (Test-Path $script:testRoot)) {
                Remove-Item $script:testRoot -Recurse -Force
            }
        }

        It "Should remove bin and obj directories" {
            $output = & $scriptPath -Path $script:testRoot
            Test-Path (Join-Path $script:testRoot "project1" "bin") | Should -Be $false
            Test-Path (Join-Path $script:testRoot "project1" "obj") | Should -Be $false
            Test-Path (Join-Path $script:testRoot "project2" "bin") | Should -Be $false
        }

        It "Should report the number of directories deleted" {
            # Re-create structure for a fresh test
            $tmpPath = [System.IO.Path]::GetTempPath()
            $freshRoot = Join-Path $tmpPath "pester-test-$(New-Guid)"
            New-Item -ItemType Directory -Path (Join-Path $freshRoot "proj" "bin") -Force | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $freshRoot "proj" "obj") -Force | Out-Null

            $output = & $scriptPath -Path $freshRoot
            $output | Should -Match 'Number of directories deleted: 2'

            if (Test-Path $freshRoot) { Remove-Item $freshRoot -Recurse -Force }
        }
    }
}

Describe "Get-PullFromGH.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $codezScriptsPath "Get-PullFromGH.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have RootFolderPath parameter" {
            $script:params | Should -Contain "RootFolderPath"
        }

        It "Should have ShowLog parameter" {
            $script:params | Should -Contain "ShowLog"
        }
    }

    Context "Functional: non-existent path handling" {
        BeforeAll {
            # Ensure Downloads directory exists as the script logs there
            $downloadsDir = Join-Path $HOME "Downloads"
            if (-not (Test-Path $downloadsDir)) {
                New-Item -ItemType Directory -Path $downloadsDir | Out-Null
            }
        }

        It "Should return an error message for a non-existent path" {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $nonExistentPath = Join-Path $tmpPath "nonexistent-folder-$(New-Guid)"
            $output = & $scriptPath -RootFolderPath $nonExistentPath 2>&1
            $output | Should -Match 'is not a directory or does not exist'
        }
    }

    Context "Functional: valid directory handling" {
        BeforeAll {
            # Ensure Downloads directory exists as the script logs there
            $downloadsDir = Join-Path $HOME "Downloads"
            if (-not (Test-Path $downloadsDir)) {
                New-Item -ItemType Directory -Path $downloadsDir | Out-Null
            }
            $tmpPath = [System.IO.Path]::GetTempPath()
            $script:testDir = Join-Path $tmpPath "pester-gh-test-$(New-Guid)"
            New-Item -ItemType Directory -Path $script:testDir | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testDir "repo1") -Force | Out-Null
        }

        AfterAll {
            if ($script:testDir -and (Test-Path $script:testDir)) {
                Remove-Item $script:testDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            $logFile = Join-Path $HOME "Downloads" "get-pullfromgh.log"
            if (Test-Path $logFile) { Remove-Item $logFile -Force }
        }

        It "Should process directories without throwing" {
            { & $scriptPath -RootFolderPath $script:testDir } | Should -Not -Throw
        }
    }
}

Describe "Search-CheatSheet.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $codezScriptsPath "Search-CheatSheet.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have Query parameter" {
            $script:params | Should -Contain "Query"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }
    }
}

Describe "Compile-Containers.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $codezScriptsPath "Compile-Containers.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have ResourceGroupName parameter" {
            $script:params | Should -Contain "ResourceGroupName"
        }

        It "Should have RegistryName parameter" {
            $script:params | Should -Contain "RegistryName"
        }

        It "Should have FolderName parameter" {
            $script:params | Should -Contain "FolderName"
        }

        It "Should have TagName parameter" {
            $script:params | Should -Contain "TagName"
        }
    }
}

Describe "All Codez scripts help content" {
    $codezScripts = Get-ChildItem -Path "$codezScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have a Synopsis section" -ForEach $codezScripts {
        $content = Get-Content $Path -Raw
        $content | Should -Match '\.SYNOPSIS'
    }
}
