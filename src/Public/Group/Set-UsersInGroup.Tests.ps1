Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-UsersInGroup.ps1"
    . "$PSScriptRoot\Get-Groups.ps1"
    . "$PSScriptRoot\..\User\Get-User.ps1"
}

Describe "Set-UsersInGroup" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $eOrg = @{id="1";name="org1"}
        $eGroupName = "group01"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $eUserIds = @("1")
        $eGroup = @{groupName=$eGroupName}
        $groups = @($eGroup)
        $eUser = @{
            loginId="user01";
            memberships=@(
                @{
                    organizationId="1";
                    groups = @("foo")
                })
            }
        Mock Get-Groups { $groups }
        Mock Get-User { $eUser }
        Mock Set-GroupMember
        Mock Write-Information
    }
    Context "Get-Orgs" {
        It "adds user to to group when not a member" {
            Set-UsersInGroup -Org $eOrg -GroupName $eGroupName -UserIds $eUserIds
            Should -Invoke Set-GroupMember -ParameterFilter { $Group -eq $eGroup -and $User -eq $eUser }
            Should -Invoke Write-Information -ParameterFilter {
                Write-Debug $Message
                $Message -eq "+adding user 'user01' to group 'group01' in org '1' ('org1')"
            }
        }
        It "does not adds user to to group when already a member" {
            $eUser.memberships[0].groups[0] = $eGroupName
            Set-UsersInGroup -Org $eOrg -GroupName $eGroupName -UserIds $eUserIds
            Should -Invoke Write-Information -ParameterFilter {
                Write-Debug $Message
                $Message -eq "# skipping user 'user01' : already member of group 'group01' in org '1 ('org1')'"
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            {$eOrg | Set-UsersInGroup -GroupName $eGroupName -UserIds $eUserIds} | Should -Not -Throw
        }
        It "ensures -Org not null" {
            {Set-UsersInGroup -Org $null -GroupName $eGroupName -UserIds $eUserIds} | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -GroupName not null" {
            {Set-UsersInGroup -Org $eOrg -GroupName $null -UserIds $eUserIds} | Should -Throw "*'GroupName'. The argument is null or empty*"
        }
        It "ensures -GroupName not empty" {
            {Set-UsersInGroup -Org $eOrg -GroupName "" -UserIds $eUserIds} | Should -Throw "*'GroupName'. The argument is null or empty*"
        }
        It "ensures -UserIds not null" {
            {Set-UsersInGroup -Org $eOrg -GroupName $eGroupName -UserIds $null} | Should -Throw "*'UserIds'. The argument is null or empty*"
        }
    }
}
