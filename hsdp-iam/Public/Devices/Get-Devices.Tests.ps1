Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Devices.ps1"
    . "$PSScriptRoot\Get-DevicesByPage.ps1"
}

Describe "Get-Devices" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $resource = @{}
        $response = @{
            entry = @($resource)
            total = 0
        }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $o = @{Id="1"}
        Mock Get-DevicesByPage { $response }
    }
    Context "calls Get-DevicesByPage" {
        It "Passes page and size" {
            Get-Devices -Org $o -Id "1"
            Should -Invoke Get-DevicesByPage -ParameterFilter { $Page -eq 1 -and $Size -eq 100}
        }
        It "By Id" {
            $result = Get-Devices -Org $o -Id "1"
            Should -Invoke Get-DevicesByPage -ParameterFilter { $Id -eq "1" }
            $result | Should -Be $resource
        }
        It "By Org" {
            $result = Get-Devices -Org $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $Org -eq $o }
            $result | Should -Be $resource
        }
        It "By App" {
            $o = @{}
            $result = Get-Devices -Org $o -App $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $App -eq $o }
            $result | Should -Be $resource
        }
        It "By DeviceExtId" {
            $o = "1"
            $result = Get-Devices -Org $o -DeviceExtId $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $DeviceExtId -eq $o }
            $result | Should -Be $resource
        }
        It "By DeviceExtType" {
            $o = "1"
            $result = Get-Devices -Org $o -DeviceExtType $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $DeviceExtType -eq $o }
            $result | Should -Be $resource
        }
        It "By DeviceExtSystem" {
            $o = "1"
            $result = Get-Devices -Org $o -DeviceExtSystem $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $DeviceExtSystem -eq $o }
            $result | Should -Be $resource
        }
        It "By LoginId" {
            $o = "1"
            $result = Get-Devices -Org $o -LoginId $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $LoginId -eq $o }
            $result | Should -Be $resource
        }
        It "By forTest" {
            $o = $true
            $result = Get-Devices -Org $o -forTest $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $forTest -eq $o }
            $result | Should -Be $resource
        }
        It "By isActive" {
            $o = $true
            $result = Get-Devices -Org $o -isActive $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $isActive -eq $o }
            $result | Should -Be $resource
        }
        It "By Type" {
            $o = "1"
            $result = Get-Devices -Org $o -Type $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $Type -eq $o }
            $result | Should -Be $resource
        }
        It "By GlobalReferenceId" {
            $o = "1"
            $result = Get-Devices -Org $o -GlobalReferenceId $o
            Should -Invoke Get-DevicesByPage -ParameterFilter { $GlobalReferenceId -eq $o }
            $result | Should -Be $resource
        }
        It "By Group" {
            $o = "1"
            $result = Get-Devices -Org $o -Group @{Id=$o}
            Should -Invoke Get-DevicesByPage -ParameterFilter { $Group.Id -eq $o }
            $result | Should -Be $resource
        }
        It "With All" {
            $o1 = @{}
            $o2 = @{}
            $result = Get-Devices -Id "1" -Org $o1 -App $o2 -DeviceExtId "2" -DeviceExtType "3" `
                -DeviceExtSystem "4" -LoginId "5" -ForTest $true -IsActive $false -Type "6" `
                -GlobalReferenceId "7" -Group @{Id="8"}
            Should -Invoke Get-DevicesByPage -ParameterFilter {
                $Id -eq "1" `
                -and $Org -eq $o1 `
                -and $App -eq $o2 `
                -and $DeviceExtId -eq "2" `
                -and $DeviceExtType -eq "3" `
                -and $DeviceExtSystem -eq "4" `
                -and $LoginId -eq "5" `
                -and $ForTest -eq $true `
                -and $IsActive -eq $false `
                -and $Type -eq "6" `
                -and $GlobalReferenceId -eq "7" `
                -and $Group.Id -eq "8"
            }
            $result | Should -Be $resource
        }

    }
}