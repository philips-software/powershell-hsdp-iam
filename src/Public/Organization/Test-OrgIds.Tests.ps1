$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Test-OrgIds.ps1"
. "$source\Get-Orgs.ps1"

Describe "Test-OrgIds" {
    $org1 = ([PSCustomObject]@{id = "1"})
    $org2 = ([PSCustomObject]@{id = "2"})
    $orgs = @($org1, $org2)
    Mock Get-Orgs { $orgs }
    Mock Write-Warning

    Context "Returns invalid org id" {
        $result = Test-OrgIds -Ids @("a", "2", "b", "1")
        Assert-MockCalled Get-Orgs
        Assert-MockCalled Write-Warning -ParameterFilter { $Message -eq "org 'a' is not a valid id" }
        Assert-MockCalled Write-Warning -ParameterFilter { $Message -eq "org 'b' is not a valid id" }
        $result.Count | Should -Be 2
        $result | Should -Be @("a", "b")
    }
}