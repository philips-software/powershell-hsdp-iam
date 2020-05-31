Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-Org.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-Org" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = ([PSCustomObject]@{id = "1"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/Organizations"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            Remove-Org -Org $org -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq "/authorize/scim/v2/Organizations/$($org.id)") `
                    -and ($Method -eq "Delete") `
                    -and ($Version -eq "2") `
                    -and ($AdditionalHeaders["If-Method"] -eq "DELETE") `
                    -and ((Compare-Object $ValidStatusCodes @(202)) -eq $null)
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline " {
            $org | Remove-Org -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            {Remove-Org -Org $null  } | Should -Throw "*'Org'. The argument is null or empty*"
        }
    }
}
