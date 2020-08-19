Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-AuthPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-AuthPolicy" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/access/Policy"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedName = "foo"
        $ExpectedPolicySetId = "9dc0d79e-eb5f-4fea-806d-254faf60d20d"
        $ExpectedOrg = @{id = "c500438e-4abd-42ec-8dc6-84b6cd241417"}
        $ExpectedResources = @("https://*:*/service/practitioner*?*")
        $ExpectedActions = @{ POST=$true; GET=$true; DELETE=$false }
        $ExpectedSubjectType = "Permission"
        $ExpectedSubjects = @("PRACTITIONER.ANY")
        $ExpectedConditions = @("openid", "mail", "read_only")
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            "name" = $ExpectedName
            "policySetId"= $ExpectedPolicySetId
            "managingOrganization" = $ExpectedOrg.Id
            "resources" = $ExpectedResources
            "actions" = $ExpectedActions
            "subject" =  @{
                type = $ExpectedSubjectType
                value = @{
                    anyOf = $ExpectedSubjects
                }
            }
            "condition" = @{
                type = "Scope"
                value = @{
                    allOf = $ExpectedConditions
                }
            }
        }
        $response = $null
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($Body | ConvertTo-Json -Depth 100)
                Write-Debug ($ExpectedBody | ConvertTo-Json -Depth 100)
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null) -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
        It "does not add subjects for subject type AuthenticatedUsers" {
            $ExpectedSubjectType = "AuthenticatedUsers"
            $ExpectedBody = @{
                "name" = $ExpectedName
                "policySetId"= $ExpectedPolicySetId
                "managingOrganization" = $ExpectedOrg.Id
                "resources" = $ExpectedResources
                "actions" = $ExpectedActions
                "subject" =  @{
                    type = $ExpectedSubjectType
                }
                "condition" = @{
                    type = "Scope"
                    value = @{
                        allOf = $ExpectedConditions
                    }
                }
            }
            Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($Body | ConvertTo-Json -Depth 100)
                Write-Debug ($ExpectedBody | ConvertTo-Json -Depth 100)
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null) -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }

        It "does not add subjects for subject type AuthenticatedPermissions" {
            $ExpectedSubjectType = "AuthenticatedPermissions"
            $ExpectedBody = @{
                "name" = $ExpectedName
                "policySetId"= $ExpectedPolicySetId
                "managingOrganization" = $ExpectedOrg.Id
                "resources" = $ExpectedResources
                "actions" = $ExpectedActions
                "subject" =  @{
                    type = $ExpectedSubjectType
                }
                "condition" = @{
                    type = "Scope"
                    value = @{
                        allOf = $ExpectedConditions
                    }
                }
            }
            Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($Body | ConvertTo-Json -Depth 100)
                Write-Debug ($ExpectedBody | ConvertTo-Json -Depth 100)
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null) -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }

    }
    Context "param" {
        It "accepts value from pipeline " {
            $ExpectedOrg | Add-AuthPolicy -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            { Add-AuthPolicy -Org $null -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $null -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'Name'. The character length (0) of the argument is too short*"
        }
        It "ensures -PolicySetId not null" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $null -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'PolicySetId'. The character length (0) of the argument is too short*"
        }
        It "ensures -Resources not null" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $null `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'Resources'. The argument is null or empty*"
        }
        It "ensures -Resources not empty" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources @() `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'Resources'. The argument is null, empty*"
        }

        It "ensures -Actions not null" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $null -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'Actions'. The argument is null or empty*"
        }
        It "ensures -Actions not empty" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions @{} -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*'Actions'. The argument is null, empty*"
        }

        It "ensures -SubjectType is valid value" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType "foo" -Subjects $ExpectedSubjects -Conditions $ExpectedConditions  } | Should -Throw "*The argument `"foo`" does not belong to the set `"AuthenticatedUsers,AuthenticatedPermissions,Permission,Group`"*"
        }

        It "ensures -Conditions not null" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions $null  } | Should -Throw "*'Conditions'. The argument is null or empty*"
        }
        It "ensures -Conditions not empty" {
            { Add-AuthPolicy -Org $ExpectedOrg -Name $ExpectedName -PolicySetId $ExpectedPolicySetId -Resources $ExpectedResources `
                -Actions $ExpectedActions -SubjectType $ExpectedSubjectType -Subjects $ExpectedSubjects -Conditions @()  } | Should -Throw "*'Conditions'. The argument is null, empty*"
        }
        It "supports positional parameters" {
            Add-AuthPolicy $ExpectedOrg $ExpectedName $ExpectedPolicySetId $ExpectedResources $ExpectedActions $ExpectedSubjectType $ExpectedSubjects $ExpectedConditions
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $ExpectedBody, $Body | Test-Equality }
        }
    }

}