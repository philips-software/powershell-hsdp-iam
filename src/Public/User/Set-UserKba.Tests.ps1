Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-UserKba.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-UserKba" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            $ExpectedBody = @{
                challenges = @(
                    @{ challenge="color"; response="blue"},
                    @{ challenge="pet"; response="fido"}
                )
            }
            Set-UserKba -User $user -ChallengeResponses @{"color"="blue"; "pet"="fido"}  -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootpath)/$($user.id)/`$kba" -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ($Body,$ExpectedBody | Test-Equality) -and `
                (Compare-Object $ValidStatusCodes @(201)) -eq $null
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | Set-UserKba -ChallengeResponses @{"color"="blue"}
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            Set-UserKba $user  @{"color"="blue"}
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { Set-UserKba $null  @{"color"="blue"} } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
