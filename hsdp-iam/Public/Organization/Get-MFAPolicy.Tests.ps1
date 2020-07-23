Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-MFAPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-MFAPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/MFAPolicies"
    }
    Context "api" {
        It "invoke request" {
            Mock Invoke-GetRequest { $response }
            $result = Get-MFAPolicy -Id "1"
            Should -Invoke Invoke-GetRequest  -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)/1" -and `
                    $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        BeforeAll {
            Mock Invoke-GetRequest { $response }
        }
        AfterEach {
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)/1" }
        }
        It "by position" {
            $result = Get-MFAPolicy "1"
            $result | Should -Be $response
        }
        It "accepts value from pipeline" {
            $result = "1" | Get-MFAPolicy
            $result | Should -Be $response
        }
    }
}