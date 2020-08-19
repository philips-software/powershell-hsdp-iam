Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-AuthPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Import-Module PesterMatchHashtable -PassThru

Describe "Remove-AuthPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $policy = ([PSCustomObject]@{id = "46d46e91-5685-49a5-b77a-75ad5e3c4873"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/access/Policy"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invoke request" {
            Remove-AuthPolicy -Policy $policy -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq "$($rootPath)/$($policy.id)") -and `
                    ($Method -eq "Delete") -and `
                    ($Version -eq "1") -and `
                    ((Compare-Object $ValidStatusCodes @(204)) -eq $null)
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $policy | Remove-AuthPolicy -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Policy not null" {
            {Remove-AuthPolicy -Policy $null -Force } | Should -Throw "*'Policy'. The argument is null or empty*"
        }
    }
}
