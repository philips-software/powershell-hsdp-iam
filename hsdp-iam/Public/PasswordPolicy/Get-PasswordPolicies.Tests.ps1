Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-PasswordPolicies.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-PasswordPolicies" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = @{Id="1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/PasswordPolicy"
        $resources = @()
        $response = @{ entry = $resources }
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Get-PasswordPolicies -Org $org
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($Org.Id)" -and `
                $Version -eq 1 -and `
                ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
            $result | Should -Be $resources
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $org | Get-PasswordPolicies
            Should -Invoke Invoke-GetRequest
        }
        It "supports by position" {
            Get-PasswordPolicies $org
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Org not null" {
            { Get-PasswordPolicies -Org $null } | Should -Throw "*'Org'. The argument is null*"
        }
    }
}