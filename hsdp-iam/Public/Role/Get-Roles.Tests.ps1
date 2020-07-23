Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Get-Roles.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-GetRequest.ps1"
}

Describe "Get-Roles" {
    BeforeAll {
        $resources = @()
        $response = [PSCustomObject]@{ entry = $resources }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Org = @{"Id" = "1"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Group = @{"Id" = "2"}
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $Name = "foo"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Role"
        Mock Invoke-GetRequest { $response }
    }
    Context "api" {
        It "invoke request for org" {
            $result = Get-Roles -Org $Org
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?organizationId=$($Org.id)" -and $Version -eq 1 }
            $result | Should -Be $resources
        }
        It "invoke request for group" {
            $result = Get-Roles -Group $Group
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?groupId=$($Group.id)" -and $Version -eq 1 }
            $result | Should -Be $resources
        }
        It "invoke request for name" {
            $result = Get-Roles -Name $Name
            Should -Invoke Invoke-GetRequest -ParameterFilter { $Path -eq "$($rootPath)?name=$($Name)" -and $Version -eq 1 }
            $result | Should -Be $resources
        }

    }
    Context "param" {
        It "accepts value from pipeline" {
            $Org | Get-Roles
            Should -Invoke Invoke-GetRequest
        }
        It "ensures -Org not null" {
            {  Get-Roles -Org $null } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -Group not null" {
            {  Get-Roles -Group $null } | Should -Throw "*'Group'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            {  Get-Roles -Name $null } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            {  Get-Roles -Name "" } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures param sets cannot be mixed" {
            {  Get-Roles -Org $Org -Group $Group } | Should -Throw "*Parameter set cannot be resolved using the specified named parameters*"
            {  Get-Roles -Org $Group -Group $Name } | Should -Throw "*Parameter set cannot be resolved using the specified named parameters*"
            {  Get-Roles -Org $Org -Group $Name } | Should -Throw "*Parameter set cannot be resolved using the specified named parameters*"
        }
    }
}