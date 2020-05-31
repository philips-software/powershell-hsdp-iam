Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-UsersByPage.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-UserByPage" {
    BeforeAll {
        Mock Invoke-GetRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = [PSCustomObject]@{ Id="1" }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $group = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/security/users"
        $response = @{
            "exchange" = @{
                "users" = @(
                    @{ "userUUID"= "06695589-af39-4928-b6db-33e52d28067f" }
                )
                "nextPageExists" = $false
            }
        }
    }
    Context "api" {
        It "invokes request" {
            $result = Get-UsersByPage -Org $org -Page 2 -Size 2
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($org.Id)&pageSize=2&pageNumber=2" -and `
                $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accept value from pipeline " {
            $result = $org | Get-UsersByPage
            Should -Invoke Invoke-GetRequest
            $result | Should -Be $response
        }
        It "uses defaults for -Page and -Size" {
            Get-UsersByPage -Org $org
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($org.Id)&pageSize=100&pageNumber=1"
            }
        }
    }
}