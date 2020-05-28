$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Add-MFAPolicy.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Add-MFAPolicy" {
    $response = [PSCustomObject]@{}
    $orgId = "1"
    $org = ([PSCustomObject]@{id = $orgId})
    $MatchBody = @{
        "schemas"= @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:MFAPolicy");
        "types" = @("SOFT_OTP");
        "name" = "foo";
        "description" = "";
        "externalId" = ""
        "active" = $true;
        "resource" = @{
            "type" = "Organization";
            "value" = $orgId;
         }
    }
    Mock Invoke-ApiRequest { $response }
    $rootPath = "/authorize/scim/v2/MFAPolicies"

    Context "Create minimal policy" {
        # Act
        $result = Add-MFAPolicy -Org $org -Name "foo" -Type "SOFT_OTP"
        # Assert
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq $rootPath -and `
            $Version -eq 2 -and `
            $Method -eq "Post" -and `
            $ValidStatusCodes -eq 201 -and `
            ($MatchBody, $Body | Test-Equality)
        }
        $result | Should -Be $response
    }
    Context "parameters" {       
        It "support org from pipeline " {
            $result = $org | Add-MFAPolicy -Name "foo" -Type "SOFT_OTP"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "ensures 'Org' is not null" {
            {Add-MFAPolicy -Org $null -Name "foo" -Type "SOFT_OTP" } | Should -Throw "Cannot validate argument on parameter 'Org'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures 'Name' is not null" {
            {Add-MFAPolicy -Org $org -Name $null -Type "SOFT_OTP" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures 'Name' is not empty" {
            {Add-MFAPolicy -Org $org -Name "" -Type "SOFT_OTP" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try the command again."
        }
        It "ensures 'Type' is one of the specified values" {
            {Add-MFAPolicy -Org $org -Name "foo" -Type $null } | Should -Throw "Cannot validate argument on parameter 'Type'. The argument `"`" does not belong to the set `"SOFT_OTP,SERVER_OTP`" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the command again."
        }
        $MatchBody.description = "description"
        $MatchBody.externalId = "externalId"
        $MatchBody.active = $false
        It "supports all by name" {
            $result = Add-MFAPolicy -Org $org -Name "foo" -Type "SOFT_OTP" -Description $MatchBody.description -ExternalId $MatchBody.externalId -Active $MatchBody.active
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
        It "supports all by position" {
            $result = Add-MFAPolicy $org "foo" "SOFT_OTP" $MatchBody.description $MatchBody.externalId $MatchBody.active
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { ($MatchBody, $Body | Test-Equality) }
            $result | Should -Be $response
        }
    }
}