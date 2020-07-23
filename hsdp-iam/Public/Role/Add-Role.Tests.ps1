Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-Role.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Role" {
    BeforeAll {
        $response = @{}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
        $Org = ([PSCustomObject]@{id = "1" })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
        $Name = "Role1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
        $Description = "RoleDesc"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
        $rootPath = "/authorize/identity/Role"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification = 'pester supported')]
        $ExpectedBody = @{
            "name"                 = $Name;
            "description"          = $Description;
            "managingOrganization" = $Org.id;
        }
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $result = Add-Role -Org $org -Name $Name -Description $Description
            $result | Should -Be $response
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 1 -and `
                $Method -eq "Post" -and `
                ($ExpectedBody, $Body | Test-Equality) -and `
                ((Compare-Object $ValidStatusCodes @(201)) -eq $null)
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $org | Add-Role -Name $Name -Description $Description
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            { Add-Role -Org $null -Name $Name -Description $Description } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            { Add-Role -Org $org -Name $null -Description $Description } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            { Add-Role -Org $org -Name "" -Description $Description } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Description not null" {
            { Add-Role -Org $org -Name $Name -Description $null } | Should -Throw "*'Description'. The argument is null or empty*"
        }
        It "ensures -Description not empty" {
            { Add-Role -Org $org -Name $Name -Description "" } | Should -Throw "*'Description'. The argument is null or empty*"
        }
        It "supports by position" {
            $org | Add-Role -Name $Name -Description $Description
            Should -Invoke Invoke-ApiRequest -ParameterFilter { ($ExpectedBody, $Body | Test-Equality) }
        }
    }
}