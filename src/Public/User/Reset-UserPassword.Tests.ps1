Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Reset-UserPassword.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Reset-UserPassword" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{loginId = "myuserlogin1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User/`$reset-password"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            $ExpectedBody = @{
                loginId = $user.loginId;
                challenges = @(
                    @{ challenge="pet"; response="fido"},
                    @{ challenge="color"; response="blue"}
                )
            }
            Reset-UserPassword -User $user -ChallengeResponses @{"color"="blue"; "pet"="fido"} -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($Body | ConvertTo-Json)
                Write-Debug ($ExpectedBody | ConvertTo-Json)
                $Path -eq "$($rootpath)" -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ($Body,$ExpectedBody | Test-Equality) -and `
                (Compare-Object $ValidStatusCodes @(202)) -eq $null
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | Reset-UserPassword -ChallengeResponses @{"color"="blue"}
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            Reset-UserPassword $user  @{"color"="blue"}
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { Reset-UserPassword $null  @{"color"="blue"} } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
