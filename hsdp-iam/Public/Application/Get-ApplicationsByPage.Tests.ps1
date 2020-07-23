Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-ApplicationsByPage.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Application" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Application?"
        Mock Invoke-GetRequest { @{total=0;entry=@()} }
    }
    Context "api" {
        It "builds path for id" {
            Get-ApplicationsByPage -Id "1" -Name "2" -GlobalReferenceId "3" -Page 1 -Size 2
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)_id=$($app.Id)&name=2&globalReferenceId=3&_count=2&_page=1" `
                -and $Version -eq 1 -and `
                ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
        }
        It "builds path for Proposition" {
            Get-ApplicationsByPage -Proposition @{Id="1"} -Name "2" -GlobalReferenceId "3" -Page 1 -Size 2
            Should -Invoke  Invoke-GetRequest -ParameterFilter {
                $Path -eq $Path -eq "$($rootPath)propositionId=1&name=2&globalReferenceId=3&_count=2&_page=1"
            }
        }
    }
    Context "param" {
        It "ensures -Id not null" {
            { Get-ApplicationsByPage -Id $null } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensures -Id not empty" {
            { Get-ApplicationsByPage -Id "" } | Should -Throw "*'Id'. The argument is null or empty*"
        }
        It "ensure -Name null or empty" {
            { Get-ApplicationsByPage -Name $null  } | Should -Throw "*'Name'. The argument is null or empty*"
            { Get-ApplicationsByPage -Name ""  } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensure -GlobalReferenceId null or empty" {
            { Get-ApplicationsByPage -GlobalReferenceId $null  } | Should -Throw "*'GlobalReferenceId'. The argument is null or empty*"
            { Get-ApplicationsByPage -GlobalReferenceId ""  } | Should -Throw "*'GlobalReferenceId'. The argument is null or empty*"
        }
    }
}