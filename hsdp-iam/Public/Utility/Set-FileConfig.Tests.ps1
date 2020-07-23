BeforeAll {
    . "$PSScriptRoot\Set-FileConfig.ps1"
    . "$PSScriptRoot\Set-Config.ps1"

}

Describe "Set-FileConfig" {
    Context "input" {
        It "reads config from xml file" {
            $config = "foo"
            Mock Set-Config
            Mock Import-CliXml { $config }
            Set-FileConfig
            Should -Invoke Import-CliXml -ParameterFilter { $Path -eq "./config.xml" }
            Should -Invoke Set-Config -ParameterFilter { $Config -eq "foo" }
        }
    }
}
