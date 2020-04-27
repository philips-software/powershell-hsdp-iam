$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Orgs.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

Describe "Get-Orgs" {
    $response = @()
    $rootPath = "/authorize/scim/v2/Organizations"
    Context "Invoke-GetRequest" {
        It "calls for all orgs" {
            Mock Invoke-GetRequest { $response }
            $orgs = Get-Orgs
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?count=10000" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $orgs | Should -Be $response
        }
    }
    Context "parameter MyOrgOnly" {
        It "uses correct path" {
            Mock Invoke-GetRequest { $response }
            $orgs = Get-Orgs -MyOrgOnly
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?myOrganizationOnly=true&count=10000" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $orgs | Should -Be $response
        }
    }
    Context "parameter Filter" {
        It "uses correct path" {
            Mock Invoke-GetRequest { $response }
            $orgs = Get-Orgs -Filter  "name eq ""DevPDSOrg"""
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?filter=name eq ""DevPDSOrg""&count=10000" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $orgs | Should -Be $response
        }
    }
    Context "parameter Filter and MyOrgOnly" {
        It "uses correct path" {
            Mock Invoke-GetRequest { $response }
            $orgs = Get-Orgs -Filter "name eq ""DevPDSOrg""" -MyOrgOnly
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?myOrganizationOnly=true&filter=name eq ""DevPDSOrg""&count=10000" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $orgs | Should -Be $response
        }
    }
}