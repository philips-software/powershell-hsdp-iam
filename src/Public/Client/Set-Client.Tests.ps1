Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-Client.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-Client" {
    BeforeAll {
        $response = [PSCustomObject]@{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Client = @{ "id" = "2"; }
        $response = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Client"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $updated = Set-Client $Client
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($Client.Id)" -and `
                $Version -eq 1 -and `
                $Method -eq "Put" -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $updated | Should -Be $response
        }
    }
    Context "params" {
        It "accepts value from pipeline " {
            $updated =  $Client | Set-Client
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($Client.Id)" }
            $updated | Should -Be $response
        }
    }
}