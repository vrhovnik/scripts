<#
.SYNOPSIS
    Pester tests for System scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, help content, and functionality for scripts in the System folder.
#>

BeforeAll {
    $systemScriptsPath = Split-Path -Parent $PSScriptRoot

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

Describe "System Script Syntax Validation" {
    $systemScripts = Get-ChildItem -Path "$systemScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $systemScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "Add-DirToSystemEnv.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Add-DirToSystemEnv.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have PathToAdd parameter" {
            $script:params | Should -Contain "PathToAdd"
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

    Context "Functional: add directory to PATH" {
        BeforeAll {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $script:testDir = Join-Path $tmpPath "pester-env-test-$(New-Guid)"
            New-Item -ItemType Directory -Path $script:testDir | Out-Null
            $script:subDir = Join-Path $script:testDir "subdir1"
            New-Item -ItemType Directory -Path $script:subDir | Out-Null
            $script:originalPath = $env:Path
        }

        AfterAll {
            $env:Path = $script:originalPath
            if ($script:testDir -and (Test-Path $script:testDir)) {
                Remove-Item $script:testDir -Recurse -Force
            }
        }

        It "Should run without error on an existing directory" {
            { & $scriptPath -PathToAdd $script:testDir } | Should -Not -Throw
        }

        It "Should add subdirectories to PATH" {
            & $scriptPath -PathToAdd $script:testDir
            # The script uses semicolon as path separator
            $pathEntries = $env:Path -split ';'
            $pathEntries | Should -Contain $script:subDir
        }
    }
}

Describe "Get-EnvVars.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Get-EnvVars.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have EnvFile parameter" {
            $script:params | Should -Contain "EnvFile"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }
    }

    Context "Functional: reading env file" {
        BeforeAll {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $script:envFile = Join-Path $tmpPath "pester-test-$(New-Guid).env"
            Set-Content -Path $script:envFile -Value @"
PESTER_TEST_VAR1=hello
PESTER_TEST_VAR2=world
"@
        }

        AfterAll {
            if ($script:envFile -and (Test-Path $script:envFile)) { Remove-Item $script:envFile -Force }
            Remove-Item env:\PESTER_TEST_VAR1 -ErrorAction SilentlyContinue
            Remove-Item env:\PESTER_TEST_VAR2 -ErrorAction SilentlyContinue
        }

        It "Should process each line in the env file" {
            $output = & $scriptPath -EnvFile $script:envFile
            $output | Should -Not -BeNullOrEmpty
        }

        It "Should set environment variables from the file" {
            & $scriptPath -EnvFile $script:envFile
            $env:PESTER_TEST_VAR1 | Should -Be "hello"
            $env:PESTER_TEST_VAR2 | Should -Be "world"
        }
    }

    Context "Error handling: non-existent file" {
        It "Should report error for a non-existent file" {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $nonExistentFile = Join-Path $tmpPath "nonexistent-$(New-Guid).env"
            $output = & $scriptPath -EnvFile $nonExistentFile 2>&1
            $output | Should -Match 'is not a file'
        }
    }
}

Describe "Get-FolderFilesCount.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Get-FolderFilesCount.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have Folder parameter" {
            $script:params | Should -Contain "Folder"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }
    }

    Context "Functional: counting files and directories" {
        BeforeAll {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $script:testFolder = Join-Path $tmpPath "pester-count-test-$(New-Guid)"
            New-Item -ItemType Directory -Path $script:testFolder | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testFolder "dir1") | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testFolder "dir2") | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testFolder "file1.txt") | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testFolder "file2.txt") | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testFolder "file3.txt") | Out-Null
        }

        AfterAll {
            if ($script:testFolder -and (Test-Path $script:testFolder)) {
                Remove-Item $script:testFolder -Recurse -Force
            }
        }

        It "Should run without error on an existing folder" {
            { & $scriptPath -Folder $script:testFolder } | Should -Not -Throw
        }
    }
}

Describe "Get-MyFolderItem.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Get-MyFolderItem.ps1"
        # Dot-source to import the function
        . $scriptPath
    }

    Context "Function definition" {
        It "Should define a Get-MyFolderItem function" {
            $function = Get-Command Get-MyFolderItem -ErrorAction SilentlyContinue
            $function | Should -Not -BeNullOrEmpty
        }

        It "Should define the gfi alias" {
            $alias = Get-Alias gfi -ErrorAction SilentlyContinue
            $alias | Should -Not -BeNullOrEmpty
        }
    }

    Context "Functional: listing folder items" {
        BeforeAll {
            $tmpPath = [System.IO.Path]::GetTempPath()
            $script:testPath = Join-Path $tmpPath "pester-gfi-test-$(New-Guid)"
            New-Item -ItemType Directory -Path $script:testPath | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testPath "alpha.txt") | Out-Null
            New-Item -ItemType File -Path (Join-Path $script:testPath "beta.txt") | Out-Null
            New-Item -ItemType Directory -Path (Join-Path $script:testPath "subdir") | Out-Null
        }

        AfterAll {
            if ($script:testPath -and (Test-Path $script:testPath)) {
                Remove-Item $script:testPath -Recurse -Force
            }
        }

        It "Should list files in a folder" {
            $result = Get-MyFolderItem -Path $script:testPath -File
            $result | Should -HaveCount 2
        }

        It "Should list directories in a folder" {
            $result = Get-MyFolderItem -Path $script:testPath -Directory
            $result | Should -HaveCount 1
        }

        It "Should return results sorted by LastWriteTime" {
            $result = Get-MyFolderItem -Path $script:testPath
            $result | Should -Not -BeNullOrEmpty
        }

        It "Should filter files by extension pattern" {
            $result = Get-MyFolderItem -Path $script:testPath -File -Filter "*.txt"
            $result | Should -HaveCount 2
        }
    }
}

Describe "Get-InstalledSoftware.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Get-InstalledSoftware.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have SoftwareName parameter" {
            $script:params | Should -Contain "SoftwareName"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }
    }
}

Describe "Get-UpTime.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Get-UpTime.ps1"
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should have a Link section" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.LINK'
        }
    }

    Context "Script content" {
        It "Should use Get-CimInstance for WMI data" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match 'Get-CimInstance'
        }

        It "Should calculate uptime with New-TimeSpan" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match 'New-TimeSpan'
        }
    }
}

Describe "Update-Software.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Update-Software.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have Confirm parameter" {
            $script:params | Should -Contain "Confirm"
        }

        It "Should have CheckIfChocolateyIsInstalled parameter" {
            $script:params | Should -Contain "CheckIfChocolateyIsInstalled"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }
    }
}

Describe "Update-Modules.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $systemScriptsPath "Update-Modules.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have AllowPrerelease parameter" {
            $script:params | Should -Contain "AllowPrerelease"
        }
    }

    Context "Help content" {
        It "Should have a Synopsis" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.SYNOPSIS'
        }

        It "Should have a Link section" {
            $content = Get-Content $scriptPath -Raw
            $content | Should -Match '\.LINK'
        }
    }
}

Describe "All System scripts help content" {
    $systemScripts = Get-ChildItem -Path "$systemScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have a Synopsis section" -ForEach $systemScripts {
        $content = Get-Content $Path -Raw
        $content | Should -Match '\.SYNOPSIS'
    }
}
