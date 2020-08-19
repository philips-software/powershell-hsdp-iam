Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-AuthPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-AuthPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/access/Policy"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedId = "3ccb1ea1-42a0-4767-bdb6-06e55310b7ae"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = @{}
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            Get-AuthPolicy -Id $ExpectedId
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($ExpectedId)" -and $Version -eq 1
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline " {
            $ExpectedId | Get-AuthPolicy
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Id not null" {
            { Get-AuthPolicy -Id $null } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensures -Id not empty" {
            { Get-AuthPolicy -Id "" } | Should -Throw "*'Id'. The argument is null or empty*"
        }
    }
}