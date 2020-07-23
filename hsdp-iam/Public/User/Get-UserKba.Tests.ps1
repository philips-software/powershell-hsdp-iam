Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-UserKba.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-UserKba" {
    BeforeEach {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = @{loginId = "myuserid1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User/`$kba"
        $response = @{challenges=@(@{color="blue"},@{pet="fido"})}
        Mock Invoke-GetRequest { $response }
    }

    Context "api" {
        It "invoke request" {
            $result = Get-UserKba -User $user
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?loginId=$($User.loginId)" -and `
                $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $ExpectedResult = @{color="blue";pet="fido"}
            ($result,$ExpectedResult | Test-Equality) | Should -BeTrue
        }

    }
    Context "param" {
        It "accept value from pipeline " {
            $user | Get-UserKba
            Should -Invoke Invoke-GetRequest
        }
        It "ensure -User not null" {
            { Get-UserKba -User $null } | Should -Throw "*'User'. The argument is null or empty.*"
        }
    }
}