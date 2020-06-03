BeforeAll {
    . "$PSScriptRoot\Invoke-Retry.ps1"
}

Describe "Invoke-Retry" {
    Context "call" {
        It "max retries" {
            Mock Write-Verbose
            Invoke-Retry { throw('Exception occured!') } -TimeoutInSecs .001 -Verbose -RetryCount 2
            Should -Invoke Write-Verbose -Exactly 8
        }
    }
}