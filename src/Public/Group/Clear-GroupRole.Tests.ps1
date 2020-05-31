Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Clear-GroupRole.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Clear-GroupRole" {
    BeforeAll {
        $group = ([PSCustomObject]@{id = "1" })
        $role = ([PSCustomObject]@{id = "2" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Group/$($Group.id)/`$remove-role"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = @{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $MatchBody = @{ "roles" = @($role.id) }
    }
    Context "api" {
        it "invoke request" {
            Mock Invoke-ApiRequest { $response }
            Clear-GroupRole -Group $group -Role $role
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath `
                    -and $Version -eq 1 `
                    -and $Method -eq "Post" `
                    -and ((Compare-Object $ValidStatusCodes @(200)) -eq $null) `
                    -and ($MatchBody, $Body | Test-Equality)
            }
        }
    }
    Context "param" {
        BeforeAll {
            Mock Invoke-ApiRequest { $response }
        }
        It "accepts value from pipeline" {
            $group | Clear-GroupRole -Role $role
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            { Clear-GroupRole -Group $null -Role $role } | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -Role not null" {
            { Clear-GroupRole -Group $group -Role $null } | Should -Throw "*'Role'. The argument is null or empty*"
        }
        It "supports by position" {
            Clear-GroupRole $group $role
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath `
                    -and $Version -eq 1 `
                    -and $Method -eq "Post" `
                    -and ((Compare-Object $ValidStatusCodes @(200)) -eq $null) `
                    -and ($MatchBody, $Body | Test-Equality)
            }
        }
    }
}