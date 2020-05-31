Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Test-UserIds.ps1"
    . "$PSScriptRoot\Get-User.ps1"
}

Describe "Test-UserIds" {
    BeforeAll {
        Mock Write-Warning
        Mock Get-User { $null }        
    }
    Context "functionality" {
        It "identifies an invalid user" {
            $result = Test-UserIds -Ids @("a")
            Should -Invoke Get-User -Times 1 -ParameterFilter { $Id -eq "a" }
            Should -Invoke Write-Warning -ParameterFilter { $Message -eq "user 'a' is not found" }
            $result | Should -Be @("a")
        }
        It "does not return an valid user" {
            $user = @{id = "1"}        
            Mock Write-Warning
            Mock Get-User { $user }
            $result = Test-UserIds -Ids @("1")
            Should -Invoke Get-User -Times 1
            $result | Should -BeNull
        } 
        It "calls for each user" {
            $result = Test-UserIds -Ids @("a", "b")
            Should -Invoke Get-User -Times 2
            $result[0] | Should -Be @("a")
            $result[1] | Should -Be @("b")
        }     
    }
    Context "param" {
        It "accepts value from pipeline" {
            @("1") | Test-UserIds
            Should -Invoke Get-User -Times 1
        }
        It "ensures -Id not null" {
            { Test-UserIds -Ids $null } `
                | Should -Throw "*'Ids'. The argument is null or empty*"
        }
    }
}