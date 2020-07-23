Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-Client.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-Client" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Client = ([PSCustomObject]@{Id = "1"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "​/authorize​/identity​/Client​"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            Remove-Client -Client $Client -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                ($Path -eq "$($rootPath)/$($Client.Id)") `
                    -and ($Method -eq "Delete") `
                    -and ($Version -eq "1") `
                    -and ((Compare-Object $ValidStatusCodes @(204)) -eq $null)
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline " {
            $Client | Remove-Client -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            {Remove-Client -Client $null  } | Should -Throw "*'Client'. The argument is null or empty*"
        }
    }
}
