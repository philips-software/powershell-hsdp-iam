Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Config.ps1"
}

Describe "Get-User" {
    Context "test" {
        It "gets script variable" {
            $config = @{}
            Mock Get-Variable { $config }
            $result = Get-Config
            Should -Invoke Get-Variable -ParameterFilter {
                $Name -eq "__config" -and `
                $Scope -eq "Script" -and `
                $ValueOnly -eq $true
            }
            $result | Should -Be $config
        }
    }
}
