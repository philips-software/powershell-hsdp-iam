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
        $role1 = [PSCustomObject]@{id="1"}
        $role2 = [PSCustomObject]@{id="2"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $roles = @($role1, $role2)
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $expectedBody = @{ "roles" = @("1","2") }
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invoke request" {
            Set-GroupRole -Group $group -Roles $roles
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
            $group | Set-GroupRole -Roles $roles
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Set-GroupRole -Group $null -Roles $roles} | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -Roles not null" {
            {Set-GroupRole -Group $group -Roles $null} | Should -Throw "*'Roles'. The argument is null or empty*"
        }
        It "ensures -Roles does not contain more than 100 roles" {
            $roles = 1..101 | ForEach-Object { New-Object PSObject -Property @{ Id = $_ } }
            {Set-GroupRole -Group $group -Roles $roles} | Should -Throw "*Maximum number of roles per request is 100*"
        }
    }
}
