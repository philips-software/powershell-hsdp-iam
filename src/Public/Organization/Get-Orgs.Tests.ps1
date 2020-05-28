$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Orgs.ps1"
. "$source\Get-OrgsByPage.ps1"

Describe "Get-Orgs" {    
    Context "get" {
        It "returns 1 page" {
            Mock Get-OrgsByPage
            Get-Orgs
            Assert-MockCalled Get-OrgsByPage -Exactly 1 -ParameterFilter {
                $Index -eq 1 -and $Size -eq 100
            }
        }
        It "supports paging" {
            $page1 = @{
                "Resources" = @("1")
                "startIndex" = 1
                "itemsPerPage" = 100
            }
            $page1 = @{
                "Resources" = @("1")
                "startIndex" = 101
                "itemsPerPage" = 1
            }
            Mock Get-OrgsByPage {
                if ($Page -eq 1) { $page1 }
                if ($Page -eq 2) { $page2 }
            }
            Get-Orgs
            Assert-MockCalled Get-OrgsByPage -Exactly 2
        }

    }
}