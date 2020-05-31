Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-GroupIdentity.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-GroupIdentity" {
    BeforeAll {
        $group = ([PSCustomObject]@{
            id = "1"
            meta = @{
                version = @("3")
            }
        })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $expectedPath = "/authorize/identity/Group/$($group.id)/`$remove"
        $MemberType = "SERVICE"
        $Ids = @("2")
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $body = @{
            "memberType" = $MemberType;
            "value"      = $Ids;
        }
        $response = @{
            meta = @{
                version = "4"
            }
        }
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            Remove-GroupIdentity -Group $group -Ids @("2") -MemberType "SERVICE"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq $expectedPath) -and `
                    ($Method -eq "Post") -and `
                    ($Version -eq "1") -and `
                    ((Compare-Object $ValidStatusCodes @(200)) -eq $null) -and `
                    ((Compare-Object $AdditionalHeaders @{"If-Match"="3"}) -eq $null)
            }
            $group.meta.version | Should -Be "4"
        }
        It "updates meta version from response" {
            Remove-GroupIdentity -Group $group -Ids @("2") -MemberType "SERVICE"
            $group.meta.version | Should -Be "4"
        }

    }
    Context "param" {
        It "accepts value from pipeline" {
            $group | Remove-GroupIdentity -Ids @("2") -MemberType "SERVICE"
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Remove-GroupIdentity -Group $null -Ids @("2") -MemberType "SERVICE" } | Should -Throw "Cannot validate argument on parameter 'Group'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -Ids not null" {
            {Remove-GroupIdentity -Group $group -Ids $null -MemberType "SERVICE" } | Should -Throw "Cannot validate argument on parameter 'Ids'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -MemberType is valid value" {
            { Remove-GroupIdentity -Group $group -Ids @("2") -MemberType "SERVICE" } | Should -Not -Throw
            { Remove-GroupIdentity -Group $group -Ids @("2") -MemberType "DEVICE" } | Should -Not -Throw
            { Remove-GroupIdentity -Group $group -Ids @("2") -MemberType "FOO" } | Should -Throw "Cannot validate argument on parameter 'MemberType'. The argument `"FOO`" does not belong to the set `"SERVICE,DEVICE`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        }
    }
}
