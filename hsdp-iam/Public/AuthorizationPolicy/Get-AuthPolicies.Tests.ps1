Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-AuthPolicies.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-AuthPolicies" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/access/Policy"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedId = "3ccb1ea1-42a0-4767-bdb6-06e55310b7ae"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $response = @{ entry=@() }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = @{Id = "d9c9b666-425b-4113-bea5-c76cb7867c2a"}
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request with org" {
            Get-AuthPolicies -Org $Org
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($Org.Id)" -and $Version -eq 1
            }
        }
        It "invoke request with PolicySetId" {
            $ExpectedPolicySetId = "13b46354-734a-4407-96d8-3b80449144e1"
            Get-AuthPolicies -PolicySetId $ExpectedPolicySetId
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?policySetId=$($ExpectedPolicySetId)" -and $Version -eq 1
            }
        }
        It "invoke request with both" {
            $ExpectedPolicySetId = "13b46354-734a-4407-96d8-3b80449144e1"
            Get-AuthPolicies -PolicySetId $ExpectedPolicySetId -Org $Org
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($Org.Id)&policySetId=$($ExpectedPolicySetId)" -and $Version -eq 1
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline " {
            $Org | Get-AuthPolicies
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Org not null" {
            { Get-AuthPolicies -Org $null } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -PolicySetId not null" {
            { Get-AuthPolicies -PolicySetId $null } | Should -Throw "*'PolicySetId'. The argument is null or empty*"
        }
        It "ensures -PolicySetId not empty" {
            { Get-AuthPolicies -PolicySetId "" } | Should -Throw "*'PolicySetId'. The argument is null or empty*"
        }

    }
}