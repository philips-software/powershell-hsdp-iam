Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Permissions.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Permissions" {
    BeforeAll {
        $resources = @()
        $response = [PSCustomObject]@{ entry = $resources }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Role = @{"Id" = "1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Permission"
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            $result = Get-Permissions -Role $role
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?roleId=$($Role.id)" -and `
                    $Version -eq 1 -and `
                    (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $resources
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $role | Get-Permissions
            Should -Invoke Invoke-GetRequest
        }
        It "supports positional" {
            Get-Permissions $role
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Role not null" {
            {  Get-Permissions -Role $null } | Should -Throw "*'Role'. The argument is null or empty*"
        }
    }
}