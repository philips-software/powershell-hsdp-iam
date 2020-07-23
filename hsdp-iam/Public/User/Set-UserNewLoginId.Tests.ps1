Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-UserNewLoginId.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-UserNewLoginId" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            $ExpectedBody = @{ loginId = "myuserid1" }
            Set-UserNewLoginId -User $user -LoginId "myuserid1" -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootpath)/$($user.id)/`$change-loginid" -and `
                $Version -eq 2 -and `
                $Method -eq "Post" -and `
                ($Body,$ExpectedBody | Test-Equality) -and `
                (Compare-Object $ValidStatusCodes @(204)) -eq $null
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | Set-UserNewLoginId -LoginId "myuserid1"
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            Set-UserNewLoginId $user "myuserid1"
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { Set-UserNewLoginId $null "myuserid1" } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -LoginId not null" {
            { Set-UserNewLoginId $user $null } `
                | Should -Throw "Cannot validate argument on parameter 'LoginId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -LoginId not empty" {
            { Set-UserNewLoginId $user "" } `
                | Should -Throw "Cannot validate argument on parameter 'LoginId'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
