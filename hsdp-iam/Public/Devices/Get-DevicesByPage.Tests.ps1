Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-DevicesByPage.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-DevicesByPage" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Device"
    }
    Context "api" {
        BeforeEach {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $org = @{Id="1"}
            Mock Invoke-GetRequest
        }
        It "checks paths are correct for parameter combinations" -TestCases @(
            @{Path = "organizationId=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org } }
            @{Path = "organizationId=1&applicationId=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -App @{Id="1"} } }
            @{Path = "organizationId=1&deviceExtId.value=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -DeviceExtId "1" } }
            @{Path = "organizationId=1&deviceExtId.value=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -DeviceExtId "%" } }
            @{Path = "organizationId=1&deviceExtId.type=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -DeviceExtType "1" } }
            @{Path = "organizationId=1&deviceExtId.type=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -DeviceExtType "%" } }
            @{Path = "organizationId=1&deviceExtId.system=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -DeviceExtSystem "1" } }
            @{Path = "organizationId=1&deviceExtId.system=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -DeviceExtSystem "%" } }
            @{Path = "organizationId=1&loginId=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -LoginId "1" } }
            @{Path = "organizationId=1&loginId=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -LoginId "%" } }
            @{Path = "organizationId=1&forTest=True&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -ForTest $true } }
            @{Path = "organizationId=1&forTest=False&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -ForTest $false } }
            @{Path = "organizationId=1&isActive=True&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -IsActive $true } }
            @{Path = "organizationId=1&isActive=False&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -IsActive $false } }
            @{Path = "organizationId=1&type=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -Type "1" } }
            @{Path = "organizationId=1&type=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -Type "%" } }
            @{Path = "organizationId=1&globalReferenceId=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -GlobalReferenceId "1" } }
            @{Path = "organizationId=1&globalReferenceId=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -GlobalReferenceId "%" } }
            @{Path = "organizationId=1&groupId=1&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -Group @{Id="1"} } }
            @{Path = "organizationId=1&groupId=%25&_count=100&_page=1"; Action = { Get-DevicesByPage -Org $org -Group  @{Id="%"} } }
            @{Path = "organizationId=1&_id=1&applicationId=2&deviceExtId.value=2&deviceExtId.type=3&deviceExtId.system=4&loginId=5&forTest=True&isActive=False&type=6&globalReferenceId=7&groupId=8&_count=1&_page=2";
                Action = {
                    Get-DevicesByPage -Org $org -Id "1" -App @{Id="2"} -DeviceExtId "2" -DeviceExtType "3" `
                    -DeviceExtSystem "4" -LoginId "5" -ForTest $true -IsActive $false -Type "6" `
                    -GlobalReferenceId "7" -Group @{Id="8"} -Page 2 -Size 1
                }
            }
        ) {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $expectedPath = $Path
            &$Action
        }
        AfterEach {
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                Write-Debug "$($rootPath)?$($expectedPath)"
                Write-Debug $Path
                $Path -eq "$($rootPath)?$($expectedPath)" -and `
                    $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
    }
}