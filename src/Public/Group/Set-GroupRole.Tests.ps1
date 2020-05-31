Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-GroupRole.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-GroupRole" {
    BeforeAll {
        $group = ([PSCustomObject]@{
            id = "1"
            meta = @{
                version = @("3")
            }
        })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $expectedPath = "/authorize/identity/Group/$($group.id)/`$assign-role"
        $role = [PSCustomObject]@{id="2"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $expectedBody = @{ "roles" = @($role.id) }
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invoke request" {
            Set-GroupRole -Group $group -Role $role
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq $expectedPath) -and `
                    ($Method -eq "Post") -and `
                    ($Version -eq 1) -and `
                    ((Compare-Object $expectedBody $Body) -eq $null) -and `
                    ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
        }
    }
    Context "params" {
        It "accepts value from pipeline" {
            $group | Set-GroupRole -Role $role
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Set-GroupRole -Group $null -Role $role} | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -User not null" {
            {Set-GroupRole -Group $group -Role $null} | Should -Throw "*'Role'. The argument is null or empty*"
        }
    }
}
