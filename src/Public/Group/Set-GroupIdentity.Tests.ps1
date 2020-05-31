Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Set-GroupIdentity.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-GroupIdentity" {
    BeforeAll {
        $group = ([PSCustomObject]@{
            id = "1"
            meta = @{
                version = @("3")
            }
        })
        $expectedPath = "/authorize/identity/Group/$($group.id)/`$assign"
        $MemberType = "SERVICE"
        $Ids = @("2")
        $expectedBody = @{
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
        It "invoke request" {            
            Set-GroupIdentity -Group $group -Ids @("2") -MemberType "SERVICE"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq $expectedPath) -and `
                    ($Method -eq "Post") -and `
                    ($Version -eq 1) -and `
                    ((Compare-Object $expectedBody $Body) -eq $null) -and `
                    ((Compare-Object $ValidStatusCodes @(200)) -eq $null) -and `
                    ((Compare-Object $AdditionalHeaders @{"If-Match"="3"}) -eq $null)
            }
            $group.meta.version | Should -Be "4"
        }
        It "updates meta version from response" {
            Set-GroupIdentity -Group $group -Ids @("2") -MemberType $MemberType
            $group.meta.version | Should -Be "4"
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $group | Set-GroupIdentity -Ids @("2") -MemberType $MemberType
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Set-GroupIdentity -Group $null -Ids @("2") -MemberType $MemberType } | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -Ids not null" {
            {Set-GroupIdentity -Group $group -Ids $null -MemberType $MemberType } | Should -Throw "*'Ids'. The argument is null or empty*"
        }
        It "ensures -MemberType is valid" {
            { Set-GroupIdentity -Group $group -Ids @("2") -MemberType "SERVICE" } | Should -Not -Throw
            { Set-GroupIdentity -Group $group -Ids @("2") -MemberType "DEVICE" } | Should -Not -Throw
            { Set-GroupIdentity -Group $group -Ids @("2") -MemberType "FOO" } | Should -Throw "*'MemberType'. The argument `"FOO`" does not belong to the set `"SERVICE,DEVICE`"*"
        }
    }
}
