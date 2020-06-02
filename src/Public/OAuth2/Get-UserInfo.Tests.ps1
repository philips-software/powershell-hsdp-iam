Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot/Get-UserInfo.ps1"
    . "$PSScriptRoot/../Utility/Get-Token.ps1"
    . "$PSScriptRoot/../Utility/Get-Config.ps1"
    . "$PSScriptRoot/../Utility/Invoke-ApiRequest.ps1"
}

Describe "Get-UserInfo" {
    BeforeAll {
        $url = "http://localhost"
        $config = @{
            IamUrl = $url
        }
        Mock Invoke-ApiRequest { "foo" }
        Mock Get-Config { $config }
        Mock Get-Token { "aaaaa" }
    }
    Context "api" {
        It "gets user info with passed token" {
            $result = Get-UserInfo -Token "123344"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "/authorize/oauth2/userinfo" -and
                $Version -eq 2 -and
                $Base -eq $url -and
                $Method -eq "Get" -and
                $Authorization -eq "Bearer 123344"
            }
            Should -Invoke Get-Token -Exactly 0
            $result | Should -Be "foo"
        }
        It "gets user info with current token" {
            Get-UserInfo
            Should -Invoke Get-Token -Exactly 1
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Authorization -eq "Bearer aaaaa"
            }

        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            "abcd" | Get-UserInfo
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Authorization -eq "Bearer abcd"
            }
        }
    }
}
