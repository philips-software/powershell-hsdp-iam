Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Role.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Role" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Role = @{"Id" = "1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Role/$($Role.Id)"
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            $result = Get-Role -Id $Role.Id
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $Role.Id | Get-Role
            Should -Invoke Invoke-GetRequest
        }
        It "supports positional" {
            Get-Role $role.Id
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Id not null" {
            {  Get-Role -Id $null } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensures -Id not empty" {
            {  Get-Role -Id "" } | Should -Throw "*'Id'. The argument is null or empty*"
        }

    }
}