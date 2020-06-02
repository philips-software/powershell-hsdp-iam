Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Introspect.ps1"
    . "$PSScriptRoot\..\Utility\Get-Token.ps1"
    . "$PSScriptRoot\..\Utility\Get-Config.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-APIRequest.ps1"
}

Describe "Get-Introspect" {
    Context "api" {
        BeforeAll {
            $config = @{
                IamUrl = "http://localhost"
            }
            Mock Invoke-ApiRequest { "0192837465" }
            Mock Get-Config { $config }
            Mock Get-Variable { "x12345x" }
        }
        It "gets introspect with token" {
            $result = Get-Introspect -Token "1234"
            $result | Should -Be "0192837465"
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Base -eq $config.IamUrl -and
                $Path -eq "/authorize/oauth2/introspect" -and
                $Version -eq 3 -and
                $Authorization -eq "Basic x12345x" -and
                $Method -eq "Post" -and
                $ContentType -eq "application/x-www-form-urlencoded" -and
                $Body -eq "token=1234"
            }
            Should -Invoke Get-Token -Exactly 0

        }
        It "gets introspect using already configured token" {
            Mock Get-Token {"5678"}
            $result = Get-Introspect
            $result | Should -Be "0192837465"
            Should -Invoke Invoke-ApiRequest -ParameterFilter { $Body -eq "token=5678"}
            Should -Invoke Get-Token -Exactly 1
        }
    }
}