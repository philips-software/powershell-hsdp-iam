Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Set-UsersToOrgGroups.ps1"
    . "$PSScriptRoot\..\Organization\Test-OrgIds.ps1"
    . "$PSScriptRoot\..\User\Test-UserIds.ps1"
    . "$PSScriptRoot\Test-GroupInOrgs.ps1"
    . "$PSScriptRoot\..\Organization\Get-Orgs.ps1"
    . "$PSScriptRoot\Set-UsersInGroup.ps1"
}

function getArray() {
    return @("1")
}
function foo() {
    getArray
}
Describe "Set-UsersToOrgGroups" {    
    BeforeAll {
        Mock Test-GroupInOrgs    
        Mock Get-Orgs
        $orgIds = @("1")
        $userIds = @("2")
        $eGroup = "group1"
    }
    Context "checks" {
        BeforeAll {
            Mock Test-OrgIds { ,@() }
            Mock Test-UserIds { ,@() }
        }
        It "tests orgs" {                    
            Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $eGroup
            Should -Invoke Test-OrgIds -ParameterFilter { $Ids -eq $orgIds }
        }
        It "tests users" {            
            Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $eGroup
            Should -Invoke Test-UserIds -ParameterFilter { $Ids -eq $userIds }
        }
        It "tests group in orgs" {
            Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $eGroup
            Should -Invoke Test-GroupInOrgs -ParameterFilter { $OrgIds -eq $orgIds -and $GroupName -eq $eGroup }
        }
        It "throws when invalid orgs ids" {
            Mock Test-OrgIds { ,@("1") }
            { Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $eGroup } | Should -Throw "Unable to continue -- Check warnings"
        }
        It "throws when invalid users ids" {
            Mock Test-UserIds { ,@("2") }
            { Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $eGroup } | Should -Throw "Unable to continue -- Check warnings"
        }    
    }
    context "process" {
        It "processes org and users" {
            Mock Test-OrgIds { ,@() }
            Mock Test-UserIds { ,@() }
            $eOrg = @{id="1"}
            Mock Get-Orgs { @($eOrg)}
            Mock Set-UsersInGroup
            Set-UsersToOrgGroups -OrgIds $orgIds -UserIds $userIds -GroupName $eGroup
            Should -Invoke Set-UsersInGroup -ParameterFilter { $Org -eq $eOrg -and $GroupName -eq $eGroup -and $UserIds[0] -eq $userIds }
        }
    }
}
