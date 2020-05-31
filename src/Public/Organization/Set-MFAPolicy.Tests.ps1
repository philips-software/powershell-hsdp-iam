Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-MFAPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-MFAPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $policy = ([PSCustomObject]@{id = "1"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = [PSCustomObject]@{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/MFAPolicies"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Set-MFAPolicy -Policy $policy
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($policy.id)" -and `
                $Method -eq "Put" -and `
                $AddIfMatch -eq $true -and
                ($Body, $policy | Test-Equality) -and
                $Version -eq 2 -and `
                $ValidStatusCodes -eq 200
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline " {
            $policy | Set-MFAPolicy
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($policy.id)" }
        }
        It "ensures -Policy not null" {
            {Set-MFAPolicy -Policy $null } | Should -Throw "Cannot validate argument on parameter 'Policy'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
