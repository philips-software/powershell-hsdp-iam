Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Set-UserPassword.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Set-UserPassword" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{loginId = "testuser01@mailinator.com" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User/`$set-password"
        Mock Invoke-ApiRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            resourceType = "Parameters";
            "parameter"=@(
              @{
                name = "setPassword";
                resource = @{
                  loginId = $user.loginId;
                  confirmationCode = "123456";
                  newPassword = "P@SSW0rd1";
                  context = "userCreate";
                }
              }
            )
        }
        $user = @{ loginId = $ExpectedBody.parameter[0].resource.loginId }
    }
    Context "api" {
        It "invokes request for userCreate context" {
            Set-UserPassword -User $user -Context "userCreate" -ConfirmationCode $ExpectedBody.parameter[0].resource.confirmationCode -NewPassword $ExpectedBody.parameter[0].resource.newPassword -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $AddHsdpApiSignature -eq $true -and `
                $Method -eq "Post" -and `
                $Path -eq "$($rootpath)" -and `
                $Version -eq 2 -and `
                (Compare-Object $ValidStatusCodes @(200)) -eq $null -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
        It "invokes request for forgotPassword context" {
            $ExpectedBody.parameter[0].resource.context = "recoverPassword"
            Set-UserPassword -User $user -Context "recoverPassword" -ConfirmationCode $ExpectedBody.parameter[0].resource.confirmationCode -NewPassword $ExpectedBody.parameter[0].resource.newPassword -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                Write-Debug ($Body | ConvertTo-Json -Depth 20)
                Write-Debug ($ExpectedBody  | ConvertTo-Json -Depth 20)
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | Set-UserPassword -Context "userCreate" -ConfirmationCode "1234" -NewPassword "passwrd" -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            Set-UserPassword $user "userCreate" "1234" -NewPassword "passwrd" -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            {Set-UserPassword -User $null -Context "userCreate" -ConfirmationCode "1234" } `
                | Should -Throw "*'User'. The argument is null or empty. Provide an argument that is not null or empty*"
        }
    }
}
