Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-PropositionsByPage.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-PropositionsByPage" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Proposition"
        Mock Invoke-GetRequest
    }
    Context "api" {
        It "invoke request" {
            Get-PropositionsByPage -Id "1"
            Should -Invoke Invoke-GetRequest -ParameterFilter {
                $Path -eq "$($rootPath)?_id=1&_count=100&_page=1" -and `
                    $Version -eq 1 -and `
                    (Compare-Object $ValidStatusCodes @(200)) -eq $null
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            "1" | Get-PropositionsByPage
            Should -Invoke Invoke-GetRequest
        }
        It "supports positional" {
            Get-PropositionsByPage "id" "name" @{Id="1"} "refid" 1 100
            Should -Invoke Invoke-GetRequest
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
        }

    }
}