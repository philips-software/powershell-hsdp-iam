Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-Permissions.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-Permissions" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Role = ([PSCustomObject]@{id = "1"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Permissions = @("PATIENT.READ", "PATIENT.WRITE")
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Role/$($Role.id)/`$remove-permission"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{ "permissions"= $Permissions; }
        $response = @{}
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Remove-Permissions -Role $Role -Permissions $Permissions
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ($ExpectedBody, $Body | Test-Equality) -and `
                $ValidStatusCodes -eq 200
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $Role | Remove-Permissions -Permissions $Permissions
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Role not null" {
            {Remove-Permissions -Role $null -Permissions $Permissions } | Should -Throw "*'Role'. The argument is null or empty*"
        }
        It "ensures -Permissions not null" {
            {Remove-Permissions -Role $Role -Permissions $null } | Should -Throw "*'Permissions'. The argument is null or empty*"
        }
        It "ensures -Permissions not empty" {
            {Remove-Permissions -Role $Role -Permissions @() } | Should -Throw "*'Permissions'. The argument is null, empty*"
        }

    }
}
