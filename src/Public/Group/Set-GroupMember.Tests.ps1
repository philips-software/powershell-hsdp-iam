Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Set-GroupMember.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-GroupMember" {
    BeforeAll {
        $group = ([PSCustomObject]@{
            id = "1"
            meta = @{
                version = @("3")
            }
        })
        $expectedPath = "/authorize/identity/Group/$($group.id)/`$add-members"
        $user = [PSCustomObject]@{id="2"}
        $expectedBody = @{
            "resourceType" = "Parameters"
            "parameter"    = @(
                @{
                    "name" = "UserIDCollection"
                    "references" = @(
                        @{ "reference" = $User.id }
                    )
                })
        }
        Mock Invoke-ApiRequest
    }
    Context "api" {        
        It "invokes request" {            
            Set-GroupMember -Group $group -User $user
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq $expectedPath) -and `
                    ($Method -eq "Post") -and `
                    ($Version -eq 1) -and `
                    ((Compare-Object $expectedBody $Body) -eq $null) -and `
                    ((Compare-Object $ValidStatusCodes @(200)) -eq $null)                    
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $group | Set-GroupMember -User $user
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Set-GroupMember -Group $null -User $user} | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -User not null" {
            {Set-GroupMember -Group $group -User $null} | Should -Throw "*'User'. The argument is null or empty*"
        }
    }
}
