BeforeAll {
    . "$PSScriptRoot\New-Config.ps1"
    . "$PSScriptRoot\Read-Config.ps1"
}

Describe "New-Config" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $config = "foo"
        Mock Read-Config { "foo" }
        Mock Export-Clixml
    }
    Context "new" {
        It "reads config from user and exports to CliXml with defaults" {
            $newConfig = New-Config
            $newConfig | Should -Be $config
            Should -Invoke Read-Config
            Should -Invoke Export-Clixml -ParameterFilter { $InputObject -eq "foo" -and $Path -eq "./config.xml" }
        }
        It "passes path to export" {
            New-Config -Path "./ci.xml"
            Should -Invoke Read-Config
            Should -Invoke Export-Clixml -ParameterFilter { $InputObject -eq "foo" -and $Path -eq "./ci.xml" }
        }
        It "does not prompt but uses the params" {
            New-Config -Prompt $False `
                -CredentialsUserName "a" -CredentialsPassword "b" `
                -ClientCredentialsUserName "c" -ClientCredentialsPassword "d" `
                -AppCredentialsUserName "e" -AppCredentialsPassword "f" `
                -OAuth2CredentialsUserName "g" -OAuth2CredentialsPassword "h" `
                -IamUrl "i" -IdmUrl "j"
            Should -Invoke Export-Clixml -ParameterFilter {
                $InputObject.Credentials.username -eq "a" -and `
                $InputObject.Credentials.GetNetworkCredential().password -eq "b" -and `
                $InputObject.ClientCredentials.username -eq "c" -and `
                $InputObject.ClientCredentials.GetNetworkCredential().password -eq "d" -and `
                $InputObject.AppCredentials.username -eq "e" -and `
                $InputObject.AppCredentials.GetNetworkCredential().password -eq "f" -and `
                $InputObject.OAuth2Credentials.username -eq "g" -and `
                $InputObject.OAuth2Credentials.GetNetworkCredential().password -eq "h" -and `
                $InputObject.IamUrl -eq "i" -and `
                $InputObject.IdmUrl -eq "j"
            }
        }

    }
}