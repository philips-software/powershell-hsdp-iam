Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Remove-GroupMember.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-GroupMember" {
    BeforeAll {
        $group = ([PSCustomObject]@{
            id = "1"
            meta = @{
                version = @("3")
            }
        })
        $user = ([PSCustomObject]@{id="2"})
        $expectedPath = "/authorize/identity/Group/$($group.id)/`$remove-members"
        $expectedBody = @{
            "resourceType" = "Parameters"
            "parameter"    = @(
                @{
                    "name"       = "UserIDCollection"
                    "references" = @(
                        @{ "reference" = $user.id }
                    )

                })
        } 
        $response = ([PSCustomObject]@{
            id="1"
            meta = @{
                version = @("4")
            }            
        })
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {        
        It "invoke request" {
            $newGroup = Remove-GroupMember -Group $group -User $user
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq $expectedPath) -and `
                    ($Method -eq "Post") -and `
                    ($Version -eq 1) -and `  
                    ((Compare-Object $Body $expectedBody) -eq $null) -and `                    
                    ((Compare-Object $ValidStatusCodes @(200)) -eq $null)                    
            }
            $newGroup | Should -Be $response
            $group.meta.version | Should -Be "4"
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $group | Remove-GroupMember -User $user
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Group not null" {
            {Remove-GroupMember -Group $null -User $user} | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -User not null" {
            {Remove-GroupMember -Group $group -User $null} | Should -Throw "*'User'. The argument is null or empty*"
        }
    }
}
