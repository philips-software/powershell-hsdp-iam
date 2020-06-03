BeforeAll {
    . "$PSScriptRoot\Wait-Action.ps1"
}

Describe "Wait-Action" {
    Context "pause" {
        It "does not wait on true" {
            Wait-Action {$true}
        }
        It "retries and times out" {
            Mock Start-Sleep
            { Wait-Action {$false} -RetryInterval .0001 -Timeout .0001} | Should -Throw "*Action timeout*"
        }
    }
}
