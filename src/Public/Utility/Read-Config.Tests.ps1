BeforeAll {
    . "$PSScriptRoot\Read-Config.ps1"
}

Describe "New-Config" {
    Context "input" {
        It "reads from user" {
            Mock Read-Host { "url"}
            Mock Write-Host
            Mock Get-Credential { "foo" }
            $config = Read-Config
            Should -Invoke Read-Host -Exactly 3
            Should -Invoke Get-Credential -Exactly 3
            $config.Credentials | Should -Be "foo"
            $config.ClientCredentials | Should -Be "foo"
            $config.AppCredentials | Should -Be "foo"
            $config.IamUrl | Should -Be "url"
            $config.IdmUrl | Should -Be "url"
        }
    }
}