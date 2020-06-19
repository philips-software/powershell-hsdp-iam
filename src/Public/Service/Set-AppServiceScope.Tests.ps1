Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-AppServiceScope.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-AppServiceScope" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $expectedPath = "/authorize/identity/Service/1/`$scopes"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $appService = @{Id="1"}
        Mock Invoke-ApiRequest
        $expectedScopes = @("hsdp.scope1","hsdp.scope2")
        $expectedDefaultScopes = @("authorize", "audit")
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            action = "add";
            scopes = $expectedScopes;
            defaultScopes = $expectedDefaultScopes;
        }
    }
    Context "api" {
        It "invoke request" {
            Set-AppServiceScope -AppService $appService -Action add -Scopes $expectedScopes -DefaultScopes $expectedDefaultScopes
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq $expectedPath) -and `
                    ($Method -eq "Put") -and `
                    ($Version -eq 1) -and `
                    ((Compare-Object $expectedBody $Body) -eq $null) -and `
                    ((Compare-Object $ValidStatusCodes @(204)) -eq $null)
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $appService | Set-AppServiceScope -Action add -Scopes $expectedScopes -DefaultScopes $expectedDefaultScopes
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -AppService not null" {
            { Set-AppServiceScope -AppService $null -Action add -Scopes $expectedScopes -DefaultScopes $expectedDefaultScopes } | Should -Throw "*'AppService'. The argument is null*"
        }
        It "ensures -Action is valid" {
            Set-AppServiceScope -AppService $appService -Action remove -Scopes $expectedScopes -DefaultScopes $expectedDefaultScopes
            { Set-AppServiceScope -AppService $appService -Action foo -Scopes $expectedScopes -DefaultScopes $expectedDefaultScopes } | Should -Throw "*'Action'. The argument `"foo`" does not belong to the set `"add,remove`"*"
        }
    }
}
