Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-UserIds.ps1"
    . "$PSScriptRoot\Get-UserIdsByPage.ps1"
}

Describe "Get-UserIds" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $objOrg = [PSCustomObject]@{ Id = "1" }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $objGroup = [PSCustomObject]@{ Id = "1" }
    }
    Context "get" {
        It "returns 1 page" {
            Mock Get-UserIdsByPage { @{
                    "exchange" = @{
                        "users"          = @(
                            @{ "userUUID" = "06695589-af39-4928-b6db-33e52d28067f" }
                        )
                        "nextPageExists" = $false
                    }
                }
            }
            $result = Get-UserIds -Org $objOrg
            Should -Invoke Get-UserIdsByPage -ParameterFilter {
                $Org -eq $objOrg -and
                $Page -eq 1
            }
            $result | Should -Be "06695589-af39-4928-b6db-33e52d28067f"
        }
        It "supports paging" {
            Mock Get-UserIdsByPage {
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
            Get-UserIds -Org $objOrg
            Should -Invoke Get-UserIdsByPage -Exactly 2
        }
    }
    Context "parameters" {
        It "support org from pipeline " {
            Mock Get-UserIdsByPage { @{
                    "exchange" = @{
                        "users"          = @(
                            @{ "userUUID" = "06695589-af39-4928-b6db-33e52d28067f" }
                        )
                        "nextPageExists" = $false
                    }
                } }
            $objOrg | Get-UserIds
            Assert-MockCalled Get-UserIdsByPage
        }
    }
}