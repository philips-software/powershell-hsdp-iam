function runTests() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',  Scope='Function')]
    param()

    BeforeAll {
        . "$PSScriptRoot\Set-Config.ps1"
        . "$PSScriptRoot\..\OAuth2\Get-Headers.ps1"
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
                $headers = "foo"
                Mock Set-Variable
                Mock Get-Headers { $headers }
            }
            It "sets script variables" {
                Set-Config $config
                Should -Invoke Set-Variable -Exactly 2
                Should -Invoke Get-Headers -Exactly 1 -ParameterFilter {
                    $IamUrl -eq $config.IamUrl -and `
                    $Credentials -eq $config.Credentials -and `
                    $ClientCredentials -eq $config.ClientCredentials
                }
            }
        }
    }
}
runTests
