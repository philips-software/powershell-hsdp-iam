Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-OrgRemoveStatus.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-OrgRemoveStatus" {
    BeforeAll {
        $status = "COMPLETE"
        $response = @{status=$status}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = @{id="1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/scim/v2/Organizations/$($Org.id)/deleteStatus"
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request" {
            $result = Get-OrgRemoveStatus -Org $Org
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq $($rootPath) -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
            $result | Should -Be $status
        }
    }
    Context "param" {
        It "supports positional" {
            Get-OrgRemoveStatus $Org
            Should -Invoke Invoke-GetRequest
        }
        It "accepts value from pipeline" {
            $Org | Get-OrgRemoveStatus
            Should -Invoke Invoke-GetRequest
        }
        It "ensure -Org is not null" {
            { Get-OrgRemoveStatus -Org $null } | Should -Throw "*Cannot bind argument to parameter 'Org' because it is null*"
        }

    }
}