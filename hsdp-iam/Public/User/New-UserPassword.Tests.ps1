Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\New-UserPassword.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "New-UserPassword" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{loginId = "testuser01@mailinator.com" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User/`$change-password"
        Mock Invoke-ApiRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            resourceType = "Parameters";
            "parameter"=@(
              @{
                name = "changePassword";
                resource = @{
                  loginId = $user.loginId;
                  newPassword = "P@ssW0rd1";
                  oldPassword = "P@ssW0rd2";
                }
              }
            )
        }
        $user = @{ loginId = $ExpectedBody.parameter[0].resource.loginId }
    }
    Context "api" {
        It "invokes request" {
            New-UserPassword -User $user -NewPassword $ExpectedBody.parameter[0].resource.newPassword -OldPassword $ExpectedBody.parameter[0].resource.oldPassword -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $AddHsdpApiSignature -eq $true -and `
                $Method -eq "Post" -and `
                $Path -eq "$($rootpath)" -and `
                $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | New-UserPassword -NewPassword "passwrd" -OldPassword "oldpassword" -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            New-UserPassword $user "oldPassword" "newPassword" -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { New-UserPassword -User $null -OldPassword "oldPassword" -NewPassword "newPassowrd" -Force} `
                | Should -Throw "*'User'. The argument is null or empty. Provide an argument that is not null or empty*"
        }
    }
}
