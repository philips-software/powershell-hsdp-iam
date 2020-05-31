Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Get-Users.ps1"
    . "$PSScriptRoot\Get-UsersByPage.ps1"
}

Describe "Get-Users" {
    BeforeAll {
        $objOrg = [PSCustomObject]@{ Id = "1" }
        $objGroup = [PSCustomObject]@{ Id = "1" }
    }
    Context "get" {
        It "returns 1 page" {
            Mock Get-UsersByPage { @{
                    "exchange" = @{
                        "users"          = @(
                            @{ "userUUID" = "06695589-af39-4928-b6db-33e52d28067f" }
                        )
                        "nextPageExists" = $false
                    }        
                }
            }
            $result = Get-Users -Org $objOrg
            Should -Invoke Get-UsersByPage -ParameterFilter {
                $Org -eq $objOrg -and
                $Page -eq 1
            }
            $result | Should -Be "06695589-af39-4928-b6db-33e52d28067f"
        }
        It "supports paging" {
            Mock Get-UsersByPage {
                if ($Page -eq 1) {
                    @{
                        "exchange" = @{ 
                            "users"          = @( @{ "userUUID" = "1" } )
                            "nextPageExists" = "true"
                        }        
                    }
                }
                if ($Page -eq 2) {
                    @{
                        "exchange" = @{ 
                            "users"          = @( @{ "userUUID" = "2" } )
                            "nextPageExists" = "false"
                        }        
                    } 
                }
            }
            Get-Users -Org $objOrg
            Should -Invoke Get-UsersByPage -Exactly 2
        }
    }
    Context "parameters" {             
        It "support org from pipeline " {
            Mock Get-UsersByPage { @{
                    "exchange" = @{
                        "users"          = @(
                            @{ "userUUID" = "06695589-af39-4928-b6db-33e52d28067f" }
                        )
                        "nextPageExists" = $false
                    }        
                } }
            $objOrg | Get-Users
            Assert-MockCalled Get-UsersByPage
        }
    }
}