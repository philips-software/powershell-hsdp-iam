$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Test-UserIds.ps1"
. "$source\Get-User.ps1"

Describe "Test-UserIds" {

    $user1 = ([PSCustomObject]@{id = "1"})
    $users = @($user1)

    Context "functionality" {
        Mock Get-User { $null }
        Mock Write-Warning
        It "identifies an invalid user" {
            $result = Test-UserIds -Ids @("a")
            Assert-MockCalled Get-User -Times 1
            Assert-MockCalled Write-Warning -ParameterFilter { $Message -eq "user 'a' is not found" }
            $result.Count | Should -Be 1
            $result | Should -Be @("a")
        }
        It "identifies an valid user" {
            $user1 = ([PSCustomObject]@{id = "1"})
            $users = @($user1)
            Mock Get-User { $users }
            Mock Write-Warning
            $result = Test-UserIds -Ids @("1")
            Assert-MockCalled Get-User -Times 1
            $result.Count | Should -Be 0
        } 
        It "calls for each user" {
            Mock Get-User { $null }
            Mock Write-Warning
            $result = Test-UserIds -Ids @("a", "b")
            Assert-MockCalled Get-User -Times 2
            $result.Count | Should -Be 2
        }     
    }
    Context "parameters" {
        Mock Get-User { $users }
        Mock Write-Warning
        It "supports Ids from pipeline" {
            @("1") | Test-UserIds
            Assert-MockCalled Get-User -Times 1
        }
        It "supports Ids from pipeline" {
            @("1") | Test-UserIds
            Assert-MockCalled Get-User -Times 1
        }
        It "requres non null Ids array" {
            { Test-UserIds -Ids $null } `
                | Should -Throw "Cannot validate argument on parameter 'Ids'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }

    }
}