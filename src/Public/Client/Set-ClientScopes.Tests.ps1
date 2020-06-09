Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-ClientScopes.ps1"
    . "$PSScriptRoot\Get-Clients.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-ClientScopes" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Client = @{ "id" = "2"; }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Client"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            scopes = @("scope_1", "scope_2")
            defaultScopes = @("scope_3", "scope_4")
        }
        Mock Invoke-ApiRequest
        Mock Get-Clients { $Client }
    }
    Context "api" {
        It "invokes request" {
            Set-ClientScopes -Client $Client -Scopes @("scope_1", "scope_2") -Defaults @("scope_3", "scope_4")
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($Client.Id)/`$Scopes" -and `
                $Version -eq 1 -and `
                $Method -eq "Put" -and `
                (Compare-Object $ValidStatusCodes @(204)) -eq $null -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
    }
    Context "params" {
        It "accepts value from pipeline " {
            $Client | Set-ClientScopes
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Path -eq $Path -eq "$($rootPath)/$($Client.Id)/$Scopes" }
        }
    }
}