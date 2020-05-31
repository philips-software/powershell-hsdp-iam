Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Get-User.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-User" {
    BeforeEach {
        $user = ([PSCustomObject]@{ })
        $response = @{
            "entry" = @($user)
        }        
        $rootPath = "/authorize/identity/User"
        $Id = "1"
        $profileType = "all"
        Mock Invoke-GetRequest { $response }
    }

    Context "api" {
        It "invoke request" {
            $result = Get-User -Id $Id
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?userId=$($Id)&profileType=$($profileType)" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200,400,401,403,406,500)) -eq $null                
            }
            $result | Should -Be $user
        }
    }
    Context "param" {       
        It "accept value from pipeline " {
            $result = $Id | Get-User
            Should -Invoke Invoke-GetRequest
            $result | Should -Be $user
        }
        It "ensure -Id not null" {
            { Get-User -Id $null } | Should -Throw "Cannot validate argument on parameter 'Id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensure -Id not empty" {
            { Get-User -Id "" } | Should -Throw "Cannot validate argument on parameter 'Id'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensure -ProfileType is valid value" {
            { Get-User -id "1" -ProfileType "foo" } | Should -Throw "Cannot validate argument on parameter 'ProfileType'. The argument `"foo`" does not belong to the set `"membership,accountStatus,passwordStatus,consentedApps,all`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        }
    }
}