Set-StrictMode -Version Latest

function runTests() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',  Scope='Function')]
    param()

    BeforeAll {
        . "$PSScriptRoot\Get-Headers.ps1"
        . "$PSScriptRoot\..\Utility\Get-Config.ps1"
        . "$PSScriptRoot\..\Utility\Invoke-APIRequest.ps1"
    }

    Describe "Get-Evaluate" {
        Context "api" {
            BeforeAll {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $url = "https://localhost/iam"

                $username1 = "username1"
                $password1 = "password1"
                $securePassword1 = ConvertTo-SecureString -String $password1 -AsPlainText -Force
                $ClientCredentials = New-Object System.Management.Automation.PSCredential ($username1, $securePassword1)

                $username2 = "username2"
                $password2 = "password2"
                $securePassword2 = ConvertTo-SecureString -String $password2 -AsPlainText -Force
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $Credentials = New-Object System.Management.Automation.PSCredential ($username2, $securePassword2)

                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $ExpectedBody =  @{
                    "grant_type" = "password"
                    "username"   = $username2
                    "password"   = $password2
                    "scope"      = "profile email READ_WRITE"
                }
                $authForToken = [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($ClientCredentials.GetNetworkCredential().username):$($ClientCredentials.GetNetworkCredential().password)"))

                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $ExpectedHeaders = @{
                    "api-version"   = "2"
                    "Content-Type"  = "application/x-www-form-urlencoded; charset=UTF-8"
                    "Accept"        = "application/json"
                    "Authorization" = "Basic $($authForToken)"
                }
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $ExpectedResult = @{
                    "Connection"    = "keep-alive"
                    "api-version"   = "2"
                    "Authorization" = "Bearer 1234567890"
                    "Accept"        = "application/json"
                    "Content-Type"  = "application/json"
                }
                Mock Invoke-RestMethod { @{ "access_token" = "1234567890"} }
            }
            It "calls using supplied values" {
                $result = Get-Headers -IamUrl $url -Credentials $Credentials -ClientCredentials $ClientCredentials
                Should -Invoke Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "$($url)/authorize/oauth2/token" -and
                    $Method -eq "Post" -and
                    ($null -eq (Compare-Object $ExpectedBody $Body))
                    ($null -eq (Compare-Object $ExpectedHeaders $Headers))
                }
                ($null -eq (Compare-Object $ExpectedResult $result)) | Should -BeTrue
                Should -Invoke Get-Config -Exactly 0
            }
            It "uses config if params not specified" {
                $config = @{
                    Credentials = $Credentials;
                    ClientCredentials = $ClientCredentials;
                    IamUrl = $url
                }
                Mock Get-Config { $config }
                $result = Get-Headers
                Should -Invoke Invoke-RestMethod -ParameterFilter {
                    $Uri -eq "$($url)/authorize/oauth2/token" -and
                    $Method -eq "Post" -and
                    ($null -eq (Compare-Object $ExpectedBody $Body))
                    ($null -eq (Compare-Object $ExpectedHeaders $Headers))
                }
                ($null -eq (Compare-Object $ExpectedResult $result)) | Should -BeTrue
                Should -Invoke Get-Config
            }
        }
    }
}
runTests
