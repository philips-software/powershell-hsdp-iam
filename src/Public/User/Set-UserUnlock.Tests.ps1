Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-UserUnlock.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-UserUnlock" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            Set-UserUnlock -User $user -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootpath)/$($user.id)/`$unlock" -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                (Compare-Object $ValidStatusCodes @(204)) -eq $null
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | Set-UserUnlock -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            Set-UserUnlock $user -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { Set-UserUnlock $null -Force } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
