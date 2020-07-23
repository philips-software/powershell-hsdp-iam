Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-User.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-User" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        $userId = "1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{id = $userId })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Remove-User -User $user
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootpath)/$($user.id)" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(204)) -eq $null
            }
            $result | Should -Be $response
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $result = $user | Remove-User
            Should -Invoke Invoke-ApiRequest
            $result | Should -Be $response
        }
        It "by position" {
            $result = Remove-User $user
            Should -Invoke Invoke-ApiRequest
            $result | Should -Be $response
        }
        It "ensures -User not null" {
            { Remove-User $null } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
