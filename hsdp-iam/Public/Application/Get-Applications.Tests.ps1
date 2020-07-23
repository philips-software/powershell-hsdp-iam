Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Applications.ps1"
    . "$PSScriptRoot\Get-ApplicationsByPage.ps1"
}

Describe "Get-Applications" {
    BeforeAll {
        $response = @{ total=0; entry=@()}
        Mock Get-ApplicationsByPage { $response }
    }
    Context "calls" {
        It "with params" {
            Get-Applications -Id "1"
            Should -Invoke Get-ApplicationsByPage -ParameterFilter {
                $Id -eq "1"
            }
        }
    }
    Context "param" {
        It "supports proposition from pipeline" {
            $prop = @{Id="1"}
            $prop | Get-Applications
            Should -Invoke Get-ApplicationsByPage  -ParameterFilter { $Proposition -eq $prop }
        }
        It "supports positional" {
            $prop = @{Id="1"}
            Get-Applications $prop "name" "GlobalReferenceId"
            Should -Invoke Get-ApplicationsByPage  -ParameterFilter {
                 $Proposition -eq $prop -and `
                 $Name -eq "name" -and `
                 $GlobalReferenceId -eq "GlobalReferenceId"
            }
        }
        It "ensure -Id null or empty" {
            { Get-Applications -Id $null  } | Should -Throw "*'Id'. The argument is null or empty*"
            { Get-Applications -Id ""  } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensure -Name null or empty" {
            { Get-Applications -Name $null  } | Should -Throw "*'Name'. The argument is null or empty*"
            { Get-Applications -Name ""  } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensure -Proposition null" {
            { Get-Applications -Proposition $null  } | Should -Throw "*'Proposition'. The argument is null or empty*"
        }
        It "ensure -GlobalReferenceId null or empty" {
            { Get-Applications -GlobalReferenceId $null  } | Should -Throw "*'GlobalReferenceId'. The argument is null or empty*"
            { Get-Applications -GlobalReferenceId ""  } | Should -Throw "*'GlobalReferenceId'. The argument is null or empty*"
        }    }
}