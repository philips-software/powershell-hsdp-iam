Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Get-Orgs.ps1"
    . "$PSScriptRoot\Get-OrgsByPage.ps1"
}

Describe "Get-Orgs" {   
    Context "paging" {
        It "returns 1 page" {
            Mock Get-OrgsByPage { @{
                    "Resources"    = @("1")
                    "startIndex"   = 1
                    "itemsPerPage" = 1
                } }
            Get-Orgs
            Should -Invoke Get-OrgsByPage -Exactly 1
        }
        It "supports paging" {
            Mock Get-OrgsByPage {
                if ($Index -eq 1) {
                    @{
                        "Resources"    = @("1")
                        "startIndex"   = 1
                        "itemsPerPage" = 100
                    }
                }
                if ($Index -eq 101) {
                    @{
                        "Resources"    = @("1")
                        "startIndex"   = 101
                        "itemsPerPage" = 1
                    }
                }
            }
            Get-Orgs
            Should -Invoke Get-OrgsByPage -Exactly 2
        }
    }
}