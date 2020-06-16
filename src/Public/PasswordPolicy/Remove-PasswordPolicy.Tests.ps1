Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-PasswordPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-PasswordPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/PasswordPolicy"
        $response = @{}
        Mock Invoke-ApiRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Policy = @{ Id = "1"; }
    }
    Context "api" {
        It "invokes request" {
            Remove-PasswordPolicy -Policy $Policy -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$rootPath/$($Policy.Id)" -and `
                    $Version -eq 1 -and `
                    $Method -eq "Delete"
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $Policy | Remove-PasswordPolicy -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Policy not null" {
            { Remove-PasswordPolicy -Policy $null -Force $null } | Should -Throw "*'Policy'. The argument is null*"
        }
   }
}