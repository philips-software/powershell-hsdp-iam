Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-Org.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-Org" {
    BeforeAll {
        $response = [PSCustomObject]@{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = @{ "id" = "2"; }
        $response = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/Organizations"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $updated = Set-Org $Org
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($Org.id)" -and `
                $Version -eq 2 -and `
                $Method -eq "Put" -and `
                $AddIfMatch -ne $null -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $updated | Should -Be $response
        }
    }
    Context "params" {
        It "accepts value from pipeline " {
            $updated =  $Org | Set-Org
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($Org.id)" }
            $updated | Should -Be $response
        }
    }
}