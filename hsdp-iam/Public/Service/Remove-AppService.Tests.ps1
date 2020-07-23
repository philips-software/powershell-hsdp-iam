Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-AppService.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-AppService" {
    BeforeAll {
        $response = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Service = ([PSCustomObject]@{id = "1"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Service/$($Service.id)"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Remove-AppService -Service $Service
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Delete" -and `
                $ValidStatusCodes -eq 204
            }
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $Service | Remove-AppService
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Service not null" {
            { Remove-AppService -Service $null } | Should -Throw "*'Service'. The argument is null or empty*"
        }
    }
}
