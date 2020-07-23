Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Propositions.ps1"
    . "$PSScriptRoot\Get-PropositionsByPage.ps1"
}

Describe "Get-Propositions" {
    BeforeAll {
        $response = @{ total=0; entry=@()}
        Mock Get-PropositionsByPage { $response }
    }
    Context "calls" {
        It "with params" {
            Get-Propositions -Id "1"
            Should -Invoke Get-PropositionsByPage -ParameterFilter {
                $Id -eq "1"
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            "1" | Get-Propositions
            Should -Invoke Get-PropositionsByPage
        }
        It "supports positional" {
            Get-Propositions "id" "name" @{Id="1"} "refid"
            Should -Invoke Get-PropositionsByPage
        }
        It "ensure -Id null or empty" {
            { Get-PropositionsByPage -Id $null  } | Should -Throw "*'Id'. The argument is null or empty*"
            { Get-PropositionsByPage -Id ""  } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensure -Name null or empty" {
            { Get-PropositionsByPage -Name $null  } | Should -Throw "*'Name'. The argument is null or empty*"
            { Get-PropositionsByPage -Name ""  } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensure -Organization null" {
            { Get-PropositionsByPage -Organization $null  } | Should -Throw "*'Organization'. The argument is null or empty*"
        }
        It "ensure -GlobalReferenceId null or empty" {
            { Get-PropositionsByPage -GlobalReferenceId $null  } | Should -Throw "*'GlobalReferenceId'. The argument is null or empty*"
            { Get-PropositionsByPage -GlobalReferenceId ""  } | Should -Throw "*'GlobalReferenceId'. The argument is null or empty*"
        }    }
}