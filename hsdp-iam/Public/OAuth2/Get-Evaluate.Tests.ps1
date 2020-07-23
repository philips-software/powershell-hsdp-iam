Set-StrictMode -Version Latest

function runTests() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',  Scope='Function')]
    param()

    BeforeAll {
        . "$PSScriptRoot\Get-Evaluate.ps1"
        . "$PSScriptRoot\..\Utility\Get-Token.ps1"
        . "$PSScriptRoot\..\Utility\Get-Config.ps1"
        . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
    }

    Describe "Get-Evaluate" {
        Context "api" {
            BeforeAll {
                $Application = @{id= "1"}
                $resources = @{}
                $token = "123"
                $username = "username"
                $password = "password"
                $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
                $config = @{
                    ClientCredentials = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
                    IamUrl = "http://localhost/"
                }
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $ExpectedAuth = ("Basic " + [convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($username):$($password)")))
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $ExpectedBody = @{
                    "application" = $Application.id;
                    "resources" = $Resources;
                    "subject" = @{
                    "type"= "ACCESS_TOKEN";
                    "value" = $token;
                    };
                }
                $ExpectedResult = @{}

                Mock Get-Config { $config }
                Mock Invoke-APIRequest { $ExpectedResult }
            }
            It "calls evaulate" {
                $result = Get-Evaluate -Application $Application -Resources $resources -Token $token
                Should -Invoke Invoke-APIRequest -ParameterFilter {
                    $Path -eq "/authorize/policy/`$evaluate" -and
                    $Version -eq 3 -and
                    $Method -eq "Post" -and
                    $Base -eq "http://localhost/" -and
                    ($null -eq (Compare-Object $expectedBody $Body)) -and `
                    ($null -eq (Compare-Object $ValidStatusCodes @(200))) -and
                    $Authorization -eq $ExpectedAuth
                }
                $result | Should -Be $ExpectedResult
            }
            It "sets token type" {
                $ExpectedBody.subject.type = "SSO_TOKEN"
                Get-Evaluate -Application $Application -Resources $resources -Token $token -TokenType "SSO_TOKEN"
                Should -Invoke Invoke-APIRequest -ParameterFilter { ($null -eq (Compare-Object $expectedBody $Body)) }
            }

        }
    }
}
runTests
