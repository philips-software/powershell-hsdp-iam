Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Clients.ps1"
    . "$PSScriptRoot\Get-ClientsByPage.ps1"
    . "$PSScriptRoot\Set-ClientScopes.ps1"
}

Describe "Get-Clients" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $resource = @{}
        $response = @{
            entry = @($resource)
            total = 0
        }
        Mock Get-ClientsByPage { $response }
        Mock Set-ClientScopes
    }
    Context "calls Get-ClientByPage" {
        It "By Id" {
            $result = Get-Clients -Id "1"
            Should -Invoke Get-ClientsByPage -ParameterFilter { $Id -eq "1" }
            $result | Should -Be $resource
        }
        It "By ClientId" {
            Get-Clients -ClientId "12345"
            Should -Invoke Get-ClientsByPage -ParameterFilter { $ClientId -eq "12345" }
        }
        It "By Name" {
            Get-Clients -Name "12345"
            Should -Invoke Get-ClientsByPage -ParameterFilter { $Name -eq "12345" }
        }
        It "By Disabled" {
            Get-Clients -Disabled
            Should -Invoke Get-ClientsByPage -ParameterFilter { $Disabled }
        }
        It "By Application" {
            $app = @{}
            Get-Clients -Application $app
            Should -Invoke Get-ClientsByPage -ParameterFilter { $Application -eq $app }
        }
        It "By GlobalReferenceId" {
            Get-Clients -GlobalReferenceId "12345"
            Should -Invoke Get-ClientsByPage -ParameterFilter { $GlobalReferenceId -eq "12345" }
        }
    }
}