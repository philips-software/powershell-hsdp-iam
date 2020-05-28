$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Group.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

function Test-HasMethod ($result, $name) {
    $result.PSObject.Methods | where-object { $_.name -eq "Assign" } | Should -HaveCount 1
}
Describe "Get-Group" {    
    Context "get" {
        $rootPath = "/authorize/identity/Group"
        It "returns group" {
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
            $result = Get-Group -Id "1"
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)/1" -and `
                $Version -eq 1
            }
            $result | Should -Be $response
            
        }
        It "adds methods to manage members" {
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
            $result = Get-Group -Id "1"
            Test-HasMethod $result "Assign"
            Test-HasMethod $result "Remove"
            Test-HasMethod $result "SetRole"
            Test-HasMethod $result "RemoveRole"
            Test-HasMethod $result "SetMember"
            Test-HasMethod $result "RemoveMember"
        }
    }
    Context "parameters" {
        It "supports positional" {
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
            Get-Group "1"
            Assert-MockCalled Invoke-GetRequest
        }
        It "supports id from pipeline" {
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
            "1" | Get-Group
            Assert-MockCalled Invoke-GetRequest            
        }
    }
}