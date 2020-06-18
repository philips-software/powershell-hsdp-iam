Set-StrictMode -Version Latest
function runTests() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '', Scope = 'Function')]
    param()

    BeforeAll {
        . "$PSScriptRoot\Get-AuthorizationHeader.ps1"
        . "$PSScriptRoot\..\Utility\Get-Config.ps1"
        . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
    }

    Describe "Get-AuthorizationHeader" {
        Context "api" {
            BeforeAll {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
                $url = "https://localhost/iam"

                $username1 = "username1"
                $password1 = "password1"
                $securePassword1 = ConvertTo-SecureString -String $password1 -AsPlainText -Force
                $ClientCredentials = New-Object System.Management.Automation.PSCredential ($username1, $securePassword1)

                $username2 = "username2"
                $password2 = "password2"
                $securePassword2 = ConvertTo-SecureString -String $password2 -AsPlainText -Force
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
                $Credentials = New-Object System.Management.Automation.PSCredential ($username2, $securePassword2)

                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
                $ExpectedBody = @{
                    "grant_type" = "password"
                    "username"   = $username2
                    "password"   = $password2
                    "scope"      = "profile email READ_WRITE"
                }
                $authForToken = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ClientCredentials.GetNetworkCredential().username):$($ClientCredentials.GetNetworkCredential().password)"))

                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
                $ExpectedHeaders = @{
                    "api-version"   = "2"
                    "Content-Type"  = "application/x-www-form-urlencoded; charset=UTF-8"
                    "Accept"        = "application/json"
                    "Authorization" = "Basic $($authForToken)"
                }
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
                $ExpectedResult = @{
                    "Connection"    = "keep-alive"
                    "api-version"   = "2"
                    "Authorization" = "Bearer 1234567890"
                    "Accept"        = "application/json"
                    "Content-Type"  = "application/json"
                }
                Mock Invoke-RestMethod {
                    @{
                        access_token = "1234567890";
                        expires_in = 30;
                    }
                }
                Mock Get-Config {
                    @{
                        IamUrl = "http://localhost";
                        Scopes = @("foo");
                    }
                }
            }
            It "calls using api using values" {
                # ensure the script varible is cleared
                $script:__authorization_header_value = $null
                $result = Get-AuthorizationHeader -IamUrl $url -Credentials $Credentials -ClientCredentials $ClientCredentials
                Should -Invoke Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "$($url)/authorize/oauth2/token" -and
                    $Method -eq "Post" -and
                    ($null -eq (Compare-Object $ExpectedBody $Body))
                    ($null -eq (Compare-Object $ExpectedHeaders $Headers))
                }
                $result | Should -Be "Bearer 1234567890"
                Should -Invoke Get-Config -Exactly 1
            }
            It "returns script value and does not call API" {
                $script:__authorization_header_value = "Bearer 28394573495"
                $script:__access_token_expires_at = (Get-Date).AddSeconds(100);
                $result = Get-AuthorizationHeader -IamUrl $url -Credentials $Credentials -ClientCredentials $ClientCredentials
                Should -Invoke Invoke-RestMethod -Exactly 0
                $result | Should -Be "Bearer 28394573495"
            }
            It "retrieves new access token using refresh token" {
                $script:__authorization_header_value = "Bearer 28394573495"
                $script:__access_token_expires_at = (Get-Date).AddSeconds(-100)
                $script:__auth.refresh_token = "aaaa"
                $result = Get-AuthorizationHeader -IamUrl $url -Credentials $Credentials -ClientCredentials $ClientCredentials
                Should -Invoke Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "$($url)/authorize/oauth2/token" -and
                    $Method -eq "Post" -and
                    ($null -eq (Compare-Object $ExpectedBody $Body))
                    ($null -eq (Compare-Object $ExpectedHeaders $Headers))
                }
                $result | Should -Be "Bearer 1234567890"
                Should -Invoke Get-Config -Exactly 1
            }
        }
    }
}
runTests

