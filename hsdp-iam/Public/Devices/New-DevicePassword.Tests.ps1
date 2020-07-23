Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\New-DevicePassword.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "New-DevicePassword" {
    BeforeAll {
        $Device = @{Id="1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $OldPasswordExpected = "P@ssword1$"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $NewPasswordExpected = "P@ssword2$"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Device/$($device.id)/`$change-password"
        Mock Invoke-ApiRequest
    }
    Context "api" {
        It "invoke request" {
            $ExpectedBody = @{
                oldPassword = $OldPasswordExpected;
                newPassword = $NewPasswordExpected;
            }
            New-DevicePassword -Device $Device -Old $OldPasswordExpected -New $NewPasswordExpected
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ((Compare-Object $ValidStatusCodes @(204)) -eq $null) -and `
                ($ExpectedBody, $Body | Test-Equality)
            }
        }
    }
    Context "param" {
        It "accepts value from pipeline" {
            $Device | New-DevicePassword -Old $OldPasswordExpected -New $NewPasswordExpected
            Should -Invoke Invoke-ApiRequest
        }
        It "accepts by position" {
            New-DevicePassword $Device $OldPasswordExpected $NewPasswordExpected
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Device is not null" {
            { New-DevicePassword -Device $null -Old $OldPasswordExpected -New $NewPasswordExpected } | Should -Throw "*'Device'. The argument is null*"
        }
        It "ensures -Old is not null" {
            { New-DevicePassword -Device $Device -Old $null -New $NewPasswordExpected } | Should -Throw "*'Old' because it is an empty string*"
        }
        It "ensures -New is greater than 7 chars" {
            { New-DevicePassword -Device $Device -Old $OldPasswordExpected -New "1234567" } | Should -Throw "*'New'. The character length (7) of the argument is too short.*"
        }
    }
}