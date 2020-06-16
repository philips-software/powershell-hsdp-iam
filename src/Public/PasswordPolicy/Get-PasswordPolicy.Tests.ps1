Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-PasswordPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-PasswordPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/PasswordPolicy"
        $response = @{ }
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Get-PasswordPolicy -Id "1"
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/1" -and `
                $Version -eq 1 -and `
                ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            "1" | Get-PasswordPolicy
            Should -Invoke Invoke-GetRequest
        }
        It "supports by position" {
            Get-PasswordPolicy "1"
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Id not null" {
            { Get-PasswordPolicy -Id $null } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensures -Id not empty" {
            { Get-PasswordPolicy -Id "" } | Should -Throw "*'Id'. The argument is null or empty*"
        }

    }
}