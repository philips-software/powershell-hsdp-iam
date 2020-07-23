Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-Device.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-Device" {
    BeforeAll {
        $response = [PSCustomObject]@{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Device = @{ "id" = "1"; }
        $response = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Device"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $updated = Set-Device $Device
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($Device.Id)" -and `
                $Version -eq 1 -and `
                $Method -eq "Put" -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $updated | Should -Be $response
        }
    }
    Context "params" {
        It "accepts value from pipeline " {
            $updated =  $Device | Set-Device
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Path -eq "$($rootPath)/$($Device.Id)" }
            $updated | Should -Be $response
        }
    }
}