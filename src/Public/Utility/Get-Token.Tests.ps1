Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Token.ps1"
}

Describe "Get-Token" {
    Context "test" {
        It "gets script level token" {
            $token = "123"
            $config = @{value=$token}
            Mock Get-Variable { $config }
            $result = Get-Token
            Should -Invoke Get-Variable -ParameterFilter {
                $Name -eq "_token" -and `
                $Scope -eq "Script"
            }
            $result | Should -Be $token
        }
    }
}
