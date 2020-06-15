Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Reset-UserMfa.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Reset-UserMfa" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            Reset-UserMfa -User $user -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootpath)/$($user.id)/`$mfa-reset" -and `
                $Version -eq 2 -and `
                $Method -eq "Post" -and `
                (Compare-Object $ValidStatusCodes @(204)) -eq $null
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | Reset-UserMfa
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            Reset-UserMfa $user
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { Reset-UserMfa $null } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
