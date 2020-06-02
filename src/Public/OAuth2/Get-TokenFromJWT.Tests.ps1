Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot/Get-TokenFromJWT.ps1"
    . "$PSScriptRoot/../Utility/Get-Config.ps1"
}

Describe "Get-TokenFromJWT" {
    Context "api" {
        BeforeAll {
            $config = @{
                IamUrl = "http://localhost"
            }
            $JWT = "12345"
            Mock Invoke-RestMethod { "0192837465" }
            Mock Get-Config { $config }
            Mock Get-Variable { "x12345x" }

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $ExpectedHeaders = @{
                "api-version"   = "1"
                "Content-Type"  = "application/x-www-form-urlencoded"
                "Accept"        = "application/json"
            }

            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
            $ExpectedBody = @{
                "grant_type"    = "urn:ietf:params:oauth:grant-type:jwt-bearer"
                "assertion"     = $JWT
            }
        }
        It "gets token for JWT" {
            $result = Get-TokenFromJWT -JWT $JWT
            $result | Should -Be "0192837465"
            Should -Invoke Invoke-RestMethod -ParameterFilter {
                $Uri -eq "$($config.IamUrl)/authorize/oauth2/token" -and
                $Method -eq "Post" -and
                ($null -eq (Compare-Object $ExpectedBody $Body))
                ($null -eq (Compare-Object $ExpectedHeaders $Headers))
            }
        }
    }
}