Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-Permissions.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Permissions" {
    BeforeAll {
        $response = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Role = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Permissions = @("PATIENT.READ", "PATIENT.WRITE")
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Role/$($Role.Id)/`$assign-permission"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{"permissions" = $Permissions;}

        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Add-Permissions -Role $Role -Permissions $Permissions
            $result | Should -Be $response
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ($ExpectedBody, $Body | Test-Equality) -and `
                ((Compare-Object $ValidStatusCodes @(200)) -eq $null)
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $Role | Add-Permissions -Permissions $Permissions
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Role not null" {
            { Add-Permissions -Role $null -Permissions $Permissions } | Should -Throw "*'Role'. The argument is null or empty*"
        }
        It "ensures -Permissions not null" {
            { Add-Permissions -Role $Role -Permissions $null } | Should -Throw "*'Permissions'. The argument is null or empty*"
        }
        It "ensures -Permissions not empty" {
            { Add-Permissions -Role $Role -Permissions @() } | Should -Throw "*'Permissions'. The argument is null, empty,*"
        }
      It "supports by position" {
            Add-Permissions $Role $Permissions
            Should -Invoke Invoke-ApiRequest -ParameterFilter { ($ExpectedBody, $Body | Test-Equality) }
        }
    }
}