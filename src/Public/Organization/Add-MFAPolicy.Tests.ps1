Set-StrictMode -Version Latest

BeforeAll {
    . "$PSScriptRoot\Add-MFAPolicy.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-MFAPolicy" {
    BeforeAll {
        $response = [PSCustomObject]@{ }
        $orgId = "1"
        [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignment', '', Justification='pester supported')]
        $org = ([PSCustomObject]@{id = $orgId })
        $MatchBody = @{
            "schemas"     = @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:MFAPolicy");
            "types"       = @("SOFT_OTP");
            "name"        = "foo";
            "description" = "";
            "externalId"  = ""
            "active"      = $true;
            "resource"    = @{
                "type"  = "Organization";
                "value" = $orgId;
            }
        }
        $rootPath = "/authorize/scim/v2/MFAPolicies"
        Mock Invoke-ApiRequest { $response } -ParameterFilter {
            $Path -eq $rootPath -and `
                $Version -eq 2 -and `
                $Method -eq "Post" -and `
                $ValidStatusCodes -eq 201 -and `
            ($MatchBody, $Body | Test-Equality)
        }
    }
    Context "api" {
        It "invokes request" {

            $result = Add-MFAPolicy -Org $org -Name "foo" -Type "SOFT_OTP"
            Should -Invoke Invoke-ApiRequest
            $result | Should -Be $response
        }
    }
    Context "param" {
        It "value from pipeline " {
            $result = $org | Add-MFAPolicy -Name "foo" -Type "SOFT_OTP"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "ensures -Org' not null" {
            { Add-MFAPolicy -Org $null -Name "foo" -Type "SOFT_OTP" } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -Name not null" {
            { Add-MFAPolicy -Org $org -Name $null -Type "SOFT_OTP" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -Name not empty" {
            { Add-MFAPolicy -Org $org -Name "" -Type "SOFT_OTP" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures -Type is valid value" {
            { Add-MFAPolicy -Org $org -Name "foo" -Type $null } | Should -Throw "Cannot validate argument on parameter 'Type'. The argument `"`" does not belong to the set `"SOFT_OTP,SERVER_OTP`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        }
        It "supports all names" {
            $MatchBody.description = "description"
            $MatchBody.externalId = "externalId"
            $MatchBody.active = $false
            $result = Add-MFAPolicy -Org $org -Name "foo" -Type "SOFT_OTP" -Description $MatchBody.description -ExternalId $MatchBody.externalId -Active $MatchBody.active
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "supports by position" {
            $result = Add-MFAPolicy $org "foo" "SOFT_OTP" $MatchBody.description $MatchBody.externalId $MatchBody.active
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
    }
}