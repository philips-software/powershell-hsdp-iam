$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Get-User.ps1"
. "$source\..\Utility\Invoke-GetRequest.ps1"

Describe "Get-User" {
    $user = ([PSCustomObject]@{ })
    $response = @{
        "entry" = @($user)
    }        
    $rootPath = "/authorize/identity/User"
    $Id = "1"
    $profileType = "all"

    Mock Invoke-GetRequest { $response }

    Context "get" {
        It "returns user when found" {
            $result = Get-User -Id $Id
            Assert-MockCalled Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?userId=$($Id)&profileType=$($profileType)" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200,400,401,403,406,500)) -eq $null                
            }
            $result | Should -Be $user
        }
    }
    Context "parameters" {       
        It "support id from pipeline " {
            $result = $Id | Get-User
            Assert-MockCalled Invoke-GetRequest
            $result | Should -Be $user
        }
        It "do not allow null id" {
            { Get-User -Id $null } | Should -Throw "Cannot validate argument on parameter 'Id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "do not allow empty id" {
            { Get-User -Id "" } | Should -Throw "Cannot validate argument on parameter 'Id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "only support valid profile" {
            { Get-User -id "1" -ProfileType "foo" } | Should -Throw "Cannot validate argument on parameter 'ProfileType'. The argument `"foo`" does not belong to the set `"membership,accountStatus,passwordStatus,consentedApps,all`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        }
    }
}