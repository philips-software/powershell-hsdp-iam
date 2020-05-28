$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-Users.ps1"
. "$source\Get-UsersByPage.ps1"

Describe "Get-Users" {    
    $objOrg = [PSCustomObject]@{ Id="1" }
    $objGroup = [PSCustomObject]@{ Id="1" }
    $response = @{
        "exchange" = @{
            "users" = @(
                @{ "userUUID"= "06695589-af39-4928-b6db-33e52d28067f" }
            )
            "nextPageExists" = $false
        }        
    }
    Context "get" {
        It "returns 1 page" {
            Mock Get-UsersByPage { $response }
            $result = Get-Users -Org $objOrg
            Assert-MockCalled Get-UsersByPage -ParameterFilter {
                $Org -eq $objOrg -and
                $Page -eq 1
            }
            $result | Should -Be "06695589-af39-4928-b6db-33e52d28067f"
        }
        It "supports paging" {
            $page1 = @{
                "exchange" = @{ 
                    "users" = @( @{ "userUUID"= "1" } )
                    "nextPageExists" = "true"
                }        
            }
            $page2 = @{
                "exchange" = @{ 
                    "users" = @( @{ "userUUID"= "2" } )
                    "nextPageExists" = "false"
                }        
            }
            Mock Get-UsersByPage {
                if ($Page -eq 1) { $page1 }
                if ($Page -eq 2) { $page2 }
            }
            Get-Users -Org $objOrg
            Assert-MockCalled Get-UsersByPage -Exactly 2
        }

    }
    Context "parameters" {     
        Mock Get-UsersByPage { $response }  
        It "support org from pipeline " {
            $org | Get-Users
            Assert-MockCalled Get-UsersByPage
        }
        It "not both org and group" {
            { Get-Users -Org $objOrg -Group $objGroup } | Should -Throw "Parameter set cannot be resolved using the specified named parameters. One or more parameters issued cannot be used together or an insufficient number of parameters were provided."
        }
    }
}