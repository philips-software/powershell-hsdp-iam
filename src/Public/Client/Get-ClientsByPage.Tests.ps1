Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-ClientsByPage.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-ClientByPage" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Client"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $clientId = "1"
        $client = @{Id=$clientId}
        $response = @{"entry"=@($client)}
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invokes request using id" {
            $result = Get-ClientsByPage -Id $clientId
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?_id=1&disabled=false&_count=100&_page=1" -and
                $Version -eq 1 -and `
                ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
            $result | Should -Be $response
        }
        It "invokes request using name" {
            Get-ClientsByPage -Name "12345"
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?name=12345&disabled=false&_count=100&_page=1" }
        }
        It "invokes request using disabled" {
            Get-ClientsByPage -Disabled
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?disabled=true&_count=100&_page=1" }
        }
        It "invokes request using application" {
            Get-ClientsByPage -Application @{Id="1"}
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?disabled=false&applicationId=1&_count=100&_page=1" }
        }
        It "invokes request using GlobalReferenceId" {
            Get-ClientsByPage -GlobalReferenceId "123"
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?disabled=false&globalReferenceId=123&_count=100&_page=1" }
        }
        It "invokes request using Page" {
            Get-ClientsByPage -Page 2
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?disabled=false&_count=100&_page=2" }
        }
        It "invokes request using Size" {
            Get-ClientsByPage -Size 1
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?disabled=false&_count=1&_page=1" }
        }
        It "invokes request using all poarams" {
            Get-ClientsByPage -Id $clientId -Name "12345" -Disabled -GlobalReferenceId "123" -Page 2 -Size 1
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?_id=1&name=12345&disabled=true&globalReferenceId=123&_count=1&_page=2" }
        }

    }
}