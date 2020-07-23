Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-Proposition.ps1"
    . "$PSScriptRoot\Get-Propositions.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Proposition" {
    BeforeAll {
        $response = [PSCustomObject]@{ "Location" =  @("4585ff25-287a-4762-b6d1-1b3dba3a9ae3") } | ConvertTo-Json
        $getProp = @{}
        $orgId = "1"
        $Name = "org1"
        $GlobalReferenceId = "2"
        $Description = "3"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = ([PSCustomObject]@{id = $orgId })
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $ExpectedBody = @{
            "organizationId"    = $org.id;
            "name"              = $Name;
            "globalReferenceId" = $GlobalReferenceId;
            "description"       = $Description;
        }
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $rootPath = "/authorize/identity/Proposition"
        Mock Invoke-ApiRequest { $response }
        Mock Get-Propositions { $getProp }
    }
    Context "api" {
        It "invokes request" {
            $added = Add-Proposition -Org $org -Name $Name -GlobalReferenceId $GlobalReferenceId -Description $Description
            $added | Should -Be $getProp
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                    $Version -eq 1 -and `
                    $Method -eq "Post" -and `
                ($ExpectedBody, $Body | Test-Equality) -and `
                $ReturnResponseHeader -eq $true -and `
                $ValidStatusCodes -eq 201
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $org | Add-Proposition -Name $Name -GlobalReferenceId $GlobalReferenceId -Description $Description
            Should -Invoke Invoke-ApiRequest
        }
        It "ensures -Org not null" {
            { Add-Proposition -Org $null -Name $Name -GlobalReferenceId $GlobalReferenceId -Description $Description } | Should -Throw "*'Org'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            { Add-Proposition -Org $org -Name $null -GlobalReferenceId $GlobalReferenceId -Description $Description } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            { Add-Proposition -Org $org -Name "" -GlobalReferenceId $GlobalReferenceId -Description $Description } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "supports -Description" {
            Add-Proposition -Org $org -Name $Name -GlobalReferenceId $GlobalReferenceId -Description $Description
            Should -Invoke Invoke-ApiRequest  -ParameterFilter { $Body.description -eq $Description }
        }
        It "supports -GlobalReferenceId" {
            Add-Proposition -Org $org -Name $Name -GlobalReferenceId $GlobalReferenceId -Description $Description
            Should -Invoke Invoke-ApiRequest  -ParameterFilter { $Body.globalReferenceId -eq $GlobalReferenceId }
        }
       It "supports by position" {
            Add-Proposition $org $Name $GlobalReferenceId $Description
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Body.organizationId -eq $org.Id -and `
                $Body.name -eq $Name -and `
                $Body.globalReferenceId -eq $GlobalReferenceId -and `
                $Body.description -eq $Description
            }
        }
    }
}