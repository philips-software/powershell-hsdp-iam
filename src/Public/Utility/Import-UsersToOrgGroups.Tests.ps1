Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Import-UsersToOrgGroups.ps1"
    . "$PSScriptRoot\..\Group\Set-UsersToOrgGroups.ps1"
}

Describe "Import-UsersToOrgGroups" {
    Context "test" {
        It "imports" {
            $csv = @(@{A="foo"})
            Mock Import-Csv { $csv }
            Mock Set-UsersToOrgGroups
            Import-UsersToOrgGroups -OrgCsvFileName "org.csv" -UserCsvFileName "user.csv" -GroupName "group1"
            Should -Invoke Import-Csv -Exactly 2
            Should -Invoke Set-UsersToOrgGroups -Exactly 1 -ParameterFilter {
                $OrgIds -eq "foo" -and
                $UserIds -eq "foo" -and
                $Groupname -eq "group1"
            }
        }
    }
}
