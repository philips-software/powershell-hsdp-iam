$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-OrgsByPage.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

Describe "Get-OrgsByPage" {
    $rootPath = "/authorize/scim/v2/Organizations"
    Context "Invoke-GetRequest" {
        Mock Invoke-GetRequest
        It "builds correct url when no parameters" {
            Get-OrgsByPage
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                Write-Debug $Path
                $Path -eq "$($rootPath)?startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -MyOrgOnly" {
            Get-OrgsByPage -MyOrgOnly
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?myOrganizationOnly=true&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -Name" {
            Get-OrgsByPage -Name "foo"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?filter=(name eq `"foo`")&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -Inactive" {
            Get-OrgsByPage -Inactive
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?filter=(active eq `"false`")&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -ParentOrg" {
            Get-OrgsByPage -ParentOrg ([PSCustomObject]@{id = "1"})
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?filter=(parent.value eq `"1`")&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -Index and -Size" {
            Get-OrgsByPage -Index 2 -Size 3
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?startIndex=2&count=3" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -MyOrgOnly and -Inactive" {
            Get-OrgsByPage -MyOrgOnly -Inactive
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?myOrganizationOnly=true&filter=(active eq `"false`")&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -Inactive and -ParentOrg and -Name" {
            Get-OrgsByPage -Inactive -ParentOrg ([PSCustomObject]@{id = "1"}) -Name "foo"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?filter=(active eq `"false`") and (parent.value eq `"1`") and (name eq `"foo`")&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
        It "builds correct url when -MyOrgOnly -Inactive and -ParentOrg and -Name" {
            Get-OrgsByPage -MyOrgOnly -Inactive -ParentOrg ([PSCustomObject]@{id = "1"}) -Name "foo"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?myOrganizationOnly=true&filter=(active eq `"false`") and (parent.value eq `"1`") and (name eq `"foo`")&startIndex=1&count=100" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }



    }
}