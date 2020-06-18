Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Token.ps1"
}

Describe "Get-Token" {
    Context "test" {
        It "gets script level token" {
            $token = "123"
            $config = @{access_token=$token}
            Mock Get-Variable { $config }
            $result = Get-Token
            Should -Invoke Get-Variable -ParameterFilter {
                $Name -eq "__auth" -and `
                $Scope -eq "Script"
            }
            $result | Should -Be $token
        }
    }
}
