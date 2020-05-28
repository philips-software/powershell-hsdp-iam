$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-UsersByPage.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

Describe "Get-UserByPage" {
    Mock Invoke-GetRequest { $response }
    $org = [PSCustomObject]@{ Id="1" }
    $group = [PSCustomObject]@{ }
    $rootPath = "/security/users"
    Context "get" {
        $response = @{
            "exchange" = @{
                "users" = @(
                    @{ "userUUID"= "06695589-af39-4928-b6db-33e52d28067f" }
                )
                "nextPageExists" = $false
            }        
        }    
        It "returns user when found" {
            $result = Get-UsersByPage -Org $org -Page 2 -Size 2
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($org.Id)&pageSize=2&pageNumber=2" -and `
                $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $response
        }
    }
    Context "parameters" {       
        It "support org from pipeline " {
            $result = $org | Get-UsersByPage
            Assert-MockCalled Invoke-GetRequest
            $result | Should -Be $response
        }
        It "Page and Size use defaults" {
            Get-UsersByPage -Org $org
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?organizationId=$($org.Id)&pageSize=100&pageNumber=1"
            }
        }
        It "not both org and group" {
            { Get-UsersByPage -Org $org -Group $group } | Should -Throw "Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an insufficient number of parameters were provided."
        }
    }
}