Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-OrgsByPage.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-OrgsByPage" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/Organizations"
    }
    Context "api" {
        BeforeEach {
            Mock Invoke-GetRequest
        }
        AfterEach {
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?$($expectedPath)" -and `
                    $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "checks paths are correct for parameter combinations" -TestCases @(
            @{Path = "startIndex=1&count=100"; Action = { Get-OrgsByPage } },
            @{Path = "myOrganizationOnly=true&startIndex=1&count=100"; Action = { Get-OrgsByPage -MyOrgOnly } }
            @{Path = "filter=(name eq `"foo`")&startIndex=1&count=100"; Action = { Get-OrgsByPage  -Name "foo" } }
            @{Path = "filter=(active eq `"false`")&startIndex=1&count=100"; Action = { Get-OrgsByPage -Inactive } }
            @{Path = "filter=(parent.value eq `"1`")&startIndex=1&count=100"; Action = { Get-OrgsByPage -ParentOrg ([PSCustomObject]@{id = "1" }) } }
            @{Path = "startIndex=2&count=3"; Action = { Get-OrgsByPage -Index 2 -Size 3 } }
            @{Path = "myOrganizationOnly=true&filter=(active eq `"false`")&startIndex=1&count=100"; Action = { Get-OrgsByPage -MyOrgOnly -Inactive } }
            @{Path = "filter=(active eq `"false`") and (parent.value eq `"1`") and (name eq `"foo`")&startIndex=1&count=100"; Action = { Get-OrgsByPage -Inactive -ParentOrg ([PSCustomObject]@{id = "1" }) -Name "foo" } }
            @{Path = "myOrganizationOnly=true&filter=(active eq `"false`") and (parent.value eq `"1`") and (name eq `"foo`")&startIndex=1&count=100"; Action = { Get-OrgsByPage -MyOrgOnly -Inactive -ParentOrg ([PSCustomObject]@{id = "1" }) -Name "foo" } }
        ) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $expectedPath = $Path
            &$Action
        }
    }
}