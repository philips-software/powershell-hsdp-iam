Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\New-UserResendActivation.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "New-UserResendActivation" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $user = ([PSCustomObject]@{loginId = "testuser01@mailinator.com" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/User/`$resend-activation"
        Mock Invoke-ApiRequest { $response }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            resourceType = "Parameters";
            "parameter"=@(
              @{
                name = "resendOTP";
                resource = @{
                  loginId = $user.loginId;
                }
              }
            )
        }
        $user = @{ loginId = $ExpectedBody.parameter[0].resource.loginId }
    }
    Context "api" {
        It "invokes request" {
            New-UserResendActivation -User $user -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $AddHsdpApiSignature -eq $true -and `
                $Method -eq "Post" -and `
                $Path -eq "$($rootpath)" -and `
                $Version -eq 1 -and `
                (Compare-Object $ValidStatusCodes @(200,202)) -eq $null -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
    }
    Context "parameters" {
        It "accept value from pipeline " {
            $user | New-UserResendActivation -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "by position" {
            New-UserResendActivation $user -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -User not null" {
            { New-UserResendActivation -User $null -Force } `
                | Should -Throw "*'User'. The argument is null or empty. Provide an argument that is not null or empty*"
        }
    }
}
