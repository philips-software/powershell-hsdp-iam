Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Invoke-GetRequest.ps1"
    . "$PSScriptRoot\Invoke-ApiRequest.ps1"
}

Describe "Invoke-GetRequest" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ThePath = "/foo"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $TheVersion = "1"
        $response = "foo"
        Mock Invoke-ApiRequest { $response }
    }
    Context "pass through" {
        It "calls Invoke-ApiRequest" {
            $result = Invoke-GetRequest -Path $ThePath -Version $TheVersion
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $ThePath -and `
                $Version -eq $TheVersion -and `
                $ValidStatusCodes -eq 200
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $ThePath | Invoke-GetRequest -Version $TheVersion
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Path not null" {
            { Invoke-GetRequest -Path $null -Version $TheVersion } | Should -Throw "*'Path'. The argument is null or empty*"
        }
        It "ensures -Path not empty" {
            { Invoke-GetRequest -Path "" -Version $TheVersion } | Should -Throw "*'Path'. The argument is null or empty*"
        }
        It "ensures -Version not null" {
            { Invoke-GetRequest -Path $ThePath -Version $null } | Should -Throw "*'Version'. The argument is null or empty*"
        }
        It "ensures -Version not empty" {
            { Invoke-GetRequest -Path $ThePath -Version "" } | Should -Throw "*'Version'. The argument is null or empty*"
        }
        It "ensures -ValidStatusCodes not empty" {
            { Invoke-GetRequest -Path $ThePath -ValidStatusCodes @() } | Should -Throw "*'ValidStatusCodes'. The argument is null, empty*"
        }
    }
}
