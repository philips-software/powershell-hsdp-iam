Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-MFAPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-MFAPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $policy = ([PSCustomObject]@{id = "1"})
        $response = [PSCustomObject]@{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/MFAPolicies"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Remove-MFAPolicy -Policy $policy
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($policy.id)" -and `
                $Version -eq 2 -and `
                $Method -eq "Delete" -and `
                $ValidStatusCodes -eq 204
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $policy | Remove-MFAPolicy
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($policy.id)" }
        }
        It "ensures -Policy not null" {
            {Remove-MFAPolicy -Policy $null } | Should -Throw "Cannot validate argument on parameter 'Policy'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
