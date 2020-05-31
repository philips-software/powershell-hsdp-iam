Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Test-OrgIds.ps1"
    . "$PSScriptRoot\Get-Orgs.ps1"
}

Describe "Test-OrgIds" {
    BeforeAll {
        $org1 = ([PSCustomObject]@{id = "1"})
        $org2 = ([PSCustomObject]@{id = "2"})
        $orgs = @($org1, $org2)
        Mock Get-Orgs { $orgs }
        Mock Write-Warning
    }
    It "returns 2 invalid orgs" {
        $result = Test-OrgIds -Ids @("a", "2", "b", "1")
        Should -Invoke Get-Orgs
        Should -Invoke Write-Warning -ParameterFilter { $Message -eq "org 'a' is not a valid id" }
        Should -Invoke Write-Warning -ParameterFilter { $Message -eq "org 'b' is not a valid id" }
        $result.Count | Should -Be 2
        $result | Should -Be @("a", "b")
    }
}