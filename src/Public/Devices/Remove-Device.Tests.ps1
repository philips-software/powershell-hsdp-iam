Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Remove-Device.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Remove-Device" {
    BeforeAll {
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Device = ([PSCustomObject]@{Id = "1"})
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Device"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invokes request" {
            Remove-Device -Device $Device -Force
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq "$($rootPath)/$($Device.Id)" `
                    -and ($Method -eq "Delete") `
                    -and ($Version -eq 1) `
                    -and $ValidStatusCodes[0] -eq 204
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline " {
            $Device | Remove-Device -Force
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            {Remove-Device $null  } | Should -Throw "*'Device'. The argument is null*"
        }
    }
}
