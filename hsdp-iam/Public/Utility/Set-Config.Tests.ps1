function runTests() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',  Scope='Function')]
    param()

    BeforeAll {
        . "$PSScriptRoot\Set-Config.ps1"
        . "$PSScriptRoot\..\OAuth2\Get-AuthorizationHeader.ps1"
    }

    Describe "Set-Config" {
        Context "input" {
            BeforeAll {
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $config = @{
                    IamUrl="a";
                    Credentials=New-Object System.Management.Automation.PSCredential ("a", (ConvertTo-SecureString -String "b "-AsPlainText -Force))
                    ClientCredentials=New-Object System.Management.Automation.PSCredential ("c", (ConvertTo-SecureString -String "d "-AsPlainText -Force))
                }
                [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
                $headers = "foo"
                Mock Set-Variable
                Mock Test-Path { $false }
                Mock Get-AuthorizationHeader
            }
            It "sets script scoped variable" {
                Set-Config $config
                Should -Invoke Set-Variable -Exactly 1 -ParameterFilter {
                    $Name -eq "__config" -and $Scope -eq "Script" -and $Value -eq $config
                }
            }
            It "clears cached authorization values and re-authenticates" {
                $script:__authorization_header_value = "x"
                $script:__access_token_expires_at = "x"
                $script:__auth = "x"
                Set-Config $config
                Should -Invoke Get-AuthorizationHeader -Exactly 1
                Get-Variable -Scope Script -ErrorAction Ignore -Name __authorization_header_value | Should -BeFalse
                Get-Variable -Scope Script -ErrorAction Ignore -Name __access_token_expires_at | Should -BeFalse
                Get-Variable -Scope Script -ErrorAction Ignore -Name __auth | Should -BeFalse
                Should -Invoke AuthorizationHeader
            }

        }
    }
}
runTests
