Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Proposition.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Org" {
    BeforeAll {
        $resources = @()
        $response = [PSCustomObject]@{ entry = $resources }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Proposition"
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            $result = Get-Proposition -Id "1"
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?_id=1" -and `
                    $Version -eq 1 -and `
                    (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $resources
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            "1" | Get-Proposition
            Should -Invoke Invoke-GetRequest
        }
        It "supports positional" {
            Get-Proposition "1"
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Id not null" {
            {  Get-Proposition -Id $null } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensures -Id not empty" {
            { Get-Proposition -Id "" } | Should -Throw "*'Id'. The argument is null or empty*"
        }

    }
}