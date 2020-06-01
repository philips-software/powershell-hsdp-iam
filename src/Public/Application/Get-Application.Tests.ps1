Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Application.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Groups" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Application?"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $app = [PSCustomObject]@{ "Id" = "1" }
        $response = @{"entry" = @($app)}
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Get-Application -Id "1"
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)_id=$($app.Id)" -and $Version -eq 1 -and
                ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
            ($result[0], $app | Test-Equality) | Should -BeTrue
        }
    }
    Context "param" {
        It "accepts org from pipeline" {
            "1" | Get-Application
            Should -Invoke  Invoke-GetRequest
        }
        It "supports positional" {
            Get-Application "1"
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Id not null" {
            { Get-Application -Id $null } | Should -Throw "*'Id' because it is an empty string*"
        }
        It "ensures -Id not empty" {
            { Get-Application -Id "" } | Should -Throw "*'Id' because it is an empty string*"
        }
    }
}