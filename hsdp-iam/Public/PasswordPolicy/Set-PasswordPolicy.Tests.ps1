Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-PasswordPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-PasswordPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/PasswordPolicy"
        $response = @{}
        Mock Invoke-ApiRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Policy = @{ Id = "1" }
    }
    Context "api" {
        It "invokes request " {
            $added = Set-PasswordPolicy -Policy $Policy
            $added | Should -Be $response
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($Policy.Id)" -and `
                    $Version -eq 1 -and `
                    $Method -eq "Put" -and `
                ($Policy, $Body | Test-Equality)
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $Policy| Set-PasswordPolicy
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Policy not null" {
            { Set-PasswordPolicy -Policy $null } | Should -Throw "*'Policy'. The argument is null*"
        }
   }
}