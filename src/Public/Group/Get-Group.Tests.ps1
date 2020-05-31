Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Group.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Group" {
    BeforeAll {
        function Test-HasMethod ($result, $name) {
            $result.PSObject.Methods | where-object { $_.name -eq $name } | Should -HaveCount 1
        }
    }
    Context "api" {
        It "invokes request" {
            $rootPath = "/authorize/identity/Group"
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
            $result = Get-Group -Id "1"
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)/1" -and `
                $Version -eq 1
            }
            $result | Should -Be $response
        }
        It "adds methods to manage members" {
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
            $result = Get-Group -Id "1"
            Test-HasMethod $result "SetIdentity"
            Test-HasMethod $result "RemoveIdentity"
            Test-HasMethod $result "SetRole"
            Test-HasMethod $result "RemoveRole"
            Test-HasMethod $result "SetMember"
            Test-HasMethod $result "RemoveMember"
        }
    }
    Context "param" {
        BeforeEach {
            $response = [PSCustomObject]@{ }
            Mock Invoke-GetRequest { $response }
        }
        It "supports by position" {
            Get-Group "1"
            Should -Invoke Invoke-GetRequest
        }
        It "accepts value from pipeline" {
            "1" | Get-Group
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Id not null" {
            { Get-Group -Id $null } | Should -Throw "*'Id'. The argument is null or empty*"
        }
    }
}