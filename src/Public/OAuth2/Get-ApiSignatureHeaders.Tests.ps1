Set-StrictMode -Version Latest

function runTests() {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '',  Scope='Function')]
    param()

    BeforeAll {
        . "$PSScriptRoot\Get-ApiSignatureHeaders.ps1"
    }

    Describe "Get-ApiSignatureHeaders" {
        BeforeAll {
            $password = ConvertTo-SecureString -String "password" -AsPlainText -Force

            $config = @{
                AppCredentials = New-Object System.Management.Automation.PSCredential ("username", $password)
            }
            Mock Get-Variable { $config }
        }
        Context "creates header" {
            It "generates correctly formatted signeddate" {
                $headers = Get-ApiSignatureHeaders
                $headers["signeddate"] | Should -Match "\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.\d*Z"
            }
            It "generates correctly formatted hsdp-api-signature" {
                $headers = Get-ApiSignatureHeaders
                $headers["hsdp-api-signature"] | Should -Match "HmacSHA256;Credential:username;SignedHeaders:SignedDate;Signature:*."
            }

        }
    }
}
runTests