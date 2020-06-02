Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-Application.ps1"
    . "$PSScriptRoot\Get-Application.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Application" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Application"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $prop = @{id = "1"}
        $appId = "127fa5aa-c8a9-4d51-b6a9-05d9016f2b37"
        $response = (@{
            location = @("http://localhost/app/$($appId)")
        }) | ConvertTo-Json
        $app = @{}
        Mock Invoke-ApiRequest { $response }
        Mock Get-Application { $app }
    }
    Context "api" {
        It "invoke request" {
            Add-Application -Proposition $prop -Name "foo" -Description "bar" -GlobalReferenceId "07b93611-2c9d-4402-b546-8d106db245d8"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $ReturnResponseHeader -eq $true -and
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null) -and `
                $Body.propositionId -eq "1" -and `
                $Body.name -eq "foo" -and
                $Body.description -eq "bar"
            }
            Should -Invoke Get-Application -ParameterFilter { $Id -eq $appId }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $prop | Add-Application -Name "foo" -GlobalReferenceId "07b93611-2c9d-4402-b546-8d106db245d8"
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Proposition not null" {
            {Add-Application -Proposition $null -Name "foo" -GlobalReferenceId "07b93611-2c9d-4402-b546-8d106db245d8"} | Should -Throw "*'Proposition'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            {Add-Application -Proposition $prop -Name $null -GlobalReferenceId "07b93611-2c9d-4402-b546-8d106db245d8"} | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            {Add-Application -Proposition $prop -Name "" -GlobalReferenceId "07b93611-2c9d-4402-b546-8d106db245d8"} | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "supports by position" {
            Add-Application $prop "foo" "2" "bar"
            Should -Invoke Invoke-ApiRequest
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Body.propositionId -eq "1" -and `
                $Body.name -eq "foo" -and
                $Body.description -eq "bar" -and
                $Body.GlobalReferenceId -eq "2"
            }

        }
    }
}