$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Org.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

Describe "Get-Org" {
    $response = [PSCustomObject]@{ }
    $rootPath = "/authorize/scim/v2/Organizations"    
    Context "get" {
        It "returns org when found" {
            Mock Invoke-GetRequest { $response }
            $org = Get-Org -Id "1"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)/1?includePolicies=false" -and `
                    $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200, 201)) -eq $null
            }
            $org | Should -Be $response
        }
        It "supports include policies" {
            Mock Invoke-GetRequest { $response }
            $org = Get-Org -Id "1" -IncludePolicies
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/1?includePolicies=true"
            }
            $org | Should -Be $response
        }
        It "supports positional" {
            Mock Invoke-GetRequest { $response }
            $org = Get-Org "1" -IncludePolicies
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/1?includePolicies=true"
            }
            $org | Should -Be $response
        }

        It "supports id from pipeline" {
            Mock Invoke-GetRequest { $response }
            $org = "1" | Get-Org
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/1?includePolicies=false"
            }
            $org | Should -Be $response
        }
    }
}