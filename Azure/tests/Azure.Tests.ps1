<#
.SYNOPSIS
    Pester tests for Azure scripts.

.DESCRIPTION
    Validates syntax, parameter definitions, and help content for all scripts in the Azure folder.
    These tests do not require an active Azure subscription.
#>

BeforeAll {
    $azureScriptsPath = Split-Path -Parent $PSScriptRoot

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

Describe "Azure Script Syntax Validation" {
    $azureScripts = Get-ChildItem -Path "$azureScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have no syntax errors" -ForEach $azureScripts {
        $result = Get-ScriptAst -ScriptPath $Path
        $result.Errors | Should -BeNullOrEmpty
    }
}

Describe "Connect-RemoteToVM.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Connect-RemoteToVM.ps1"
        $result = Get-ScriptAst -ScriptPath $scriptPath
        $script:ast = $result.Ast
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have VmName parameter" {
            $script:params | Should -Contain "VmName"
        }

        It "Should have ResourceGroupName parameter" {
            $script:params | Should -Contain "ResourceGroupName"
        }

        It "Should have AutoStart parameter" {
            $script:params | Should -Contain "AutoStart"
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
}

Describe "Get-IpAddressesFromServiceTag.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Get-IpAddressesFromServiceTag.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have RegionName parameter" {
            $script:params | Should -Contain "RegionName"
        }

        It "Should have ServiceName parameter" {
            $script:params | Should -Contain "ServiceName"
        }
    }

    Context "Default parameter values" {
        It "Script AST should contain default value WestEurope for RegionName" {
            $content = Get-Content (Join-Path $azureScriptsPath "Get-IpAddressesFromServiceTag.ps1") -Raw
            $content | Should -Match 'WestEurope'
        }

        It "Script AST should contain default value MicrosoftContainerRegistry for ServiceName" {
            $content = Get-Content (Join-Path $azureScriptsPath "Get-IpAddressesFromServiceTag.ps1") -Raw
            $content | Should -Match 'MicrosoftContainerRegistry'
        }
    }
}

Describe "Start-Machine.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Start-Machine.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have VmName parameter" {
            $script:params | Should -Contain "VmName"
        }

        It "Should have ResourceGroupName parameter" {
            $script:params | Should -Contain "ResourceGroupName"
        }
    }
}

Describe "Get-AppInsightsTypes.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Get-AppInsightsTypes.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have SubscriptionId parameter" {
            $script:params | Should -Contain "SubscriptionId"
        }
    }
}

Describe "Get-AppSecurityKeyExpiration.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Get-AppSecurityKeyExpiration.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have NumberOfDays parameter" {
            $script:params | Should -Contain "NumberOfDays"
        }

        It "Should have InstallDependency parameter" {
            $script:params | Should -Contain "InstallDependency"
        }
    }

    Context "Default parameter values" {
        It "Script should contain default value of 30 for NumberOfDays" {
            $content = Get-Content (Join-Path $azureScriptsPath "Get-AppSecurityKeyExpiration.ps1") -Raw
            $content | Should -Match '\$NumberOfDays\s*=\s*30'
        }
    }
}

Describe "Enable-PSRemote.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Enable-PSRemote.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have VmName parameter" {
            $script:params | Should -Contain "VmName"
        }

        It "Should have ResourceGroupName parameter" {
            $script:params | Should -Contain "ResourceGroupName"
        }

        It "Should have EstablishRemoteConnection parameter" {
            $script:params | Should -Contain "EstablishRemoteConnection"
        }
    }
}

Describe "Set-ApplicationInsightRetention.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Set-ApplicationInsightRetention.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have SubscriptionId parameter" {
            $script:params | Should -Contain "SubscriptionId"
        }

        It "Should have ResourceGroupName parameter" {
            $script:params | Should -Contain "ResourceGroupName"
        }

        It "Should have Name parameter" {
            $script:params | Should -Contain "Name"
        }

        It "Should have RetentionInDays parameter" {
            $script:params | Should -Contain "RetentionInDays"
        }
    }
}

Describe "Send-Email.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Send-Email.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have ToUser parameter" {
            $script:params | Should -Contain "ToUser"
        }

        It "Should have Subject parameter" {
            $script:params | Should -Contain "Subject"
        }

        It "Should have Body parameter" {
            $script:params | Should -Contain "Body"
        }
    }
}

Describe "Get-VmNSG.ps1" {
    BeforeAll {
        $scriptPath = Join-Path $azureScriptsPath "Get-VmNSG.ps1"
        $script:params = Get-ScriptParameters -ScriptPath $scriptPath
    }

    Context "Parameter validation" {
        It "Should have VmName parameter" {
            $script:params | Should -Contain "VmName"
        }

        It "Should have ResourceGroupName parameter" {
            $script:params | Should -Contain "ResourceGroupName"
        }
    }
}

Describe "All Azure scripts help content" {
    $azureScripts = Get-ChildItem -Path "$azureScriptsPath" -Filter "*.ps1" |
        ForEach-Object { @{ Name = $_.Name; Path = $_.FullName } }

    It "<Name> should have a Synopsis section" -ForEach $azureScripts {
        $content = Get-Content $Path -Raw
        $content | Should -Match '\.SYNOPSIS'
    }
}
