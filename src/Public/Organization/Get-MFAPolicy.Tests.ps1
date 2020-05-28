$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-MFAPolicy.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

Describe "Get-MFAPolicy" {
    $response = [PSCustomObject]@{ }
    $rootPath = "/authorize/scim/v2/MFAPolicies"    
    Context "get" {
        It "returns MFAPolicy when found" {
            Mock Invoke-GetRequest { $response }
            $result = Get-MFAPolicy -Id "1"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)/1" -and `
                    $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $response
        }
        It "supports positional" {
            Mock Invoke-GetRequest { $response }
            $result = Get-MFAPolicy "1"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/1"
            }
            $result | Should -Be $response
        }

        It "supports id from pipeline" {
            Mock Invoke-GetRequest { $response }
            $result = "1" | Get-MFAPolicy
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)/1"
            }
            $result | Should -Be $response
        }
    }
}