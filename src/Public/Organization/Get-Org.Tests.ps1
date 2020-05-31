Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Org.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Org" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/Organizations"
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            $org = Get-Org -Id "1"
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)/1?includePolicies=false" -and `
                    $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200, 201)) -eq $null
            }
            $org | Should -Be $response
        }
        It "includes policies" {
            $org = Get-Org -Id "1" -IncludePolicies
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)/1?includePolicies=true" }
            $org | Should -Be $response
        }
    }
    Context "param" {
        It "supports positional" {
            Get-Org "1" -IncludePolicies
            Should -Invoke Invoke-GetRequest -ParameterFilter { Write-Debug $Path; $Path -eq "$($rootPath)/1?includePolicies=true" }
        }
        It "accepts value from pipeline" {
            "1" | Get-Org
            Should -Invoke Invoke-GetRequest -ParameterFilter { Write-Debug $Path; $Path -eq "$($rootPath)/1?includePolicies=false" }
        }
    }
}