$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Remove-User.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Add-User" {
    $response = [PSCustomObject]@{ }
    $userId = "1"
    $user = ([PSCustomObject]@{id = $userId })
    $rootPath = "/authorize/identity/User"

    Mock Invoke-ApiRequest { $response } 

    Context "Create a minimal user" {
        $result = Remove-User -User $user
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq "$($rootpath)/$($user.id)" -and `
            $Version -eq 2 -and `
            (Compare-Object $ValidStatusCodes @(204)) -eq $null
        }
        $result | Should -Be $response
    }
    Context "parameters" {       
        It "support user from pipeline " {
            $result = $user | Remove-User
            Assert-MockCalled Invoke-ApiRequest
            $result | Should -Be $response
        }
        It "support parameters by position" {
            $result = Remove-User $user
            Assert-MockCalled Invoke-ApiRequest
            $result | Should -Be $response
        }
        It "requires non-null user " {
            { Remove-User $null } `
                | Should -Throw "Cannot validate argument on parameter 'User'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
    }
}
