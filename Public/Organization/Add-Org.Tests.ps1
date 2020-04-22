$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Add-Org.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Add-Org" {
    $response = [PSCustomObject]@{}
    $parentOrgId = "1"
    $parentOrgObject = ([PSCustomObject]@{id = $parentOrgId})
    $MatchBody = @{
        "schemas"= @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:Organization");
        "displayName" = "";
        "name" = "foo";
        "description" = "";
        "parent" = @{
            "value" = $parentOrgId;
         };
         "externalId" = ""
         "type"= ""
         "address" = @{
            "formatted" = ""
            "streetAddress" = ""
            "locality" = ""
            "region" = ""
            "postalCode" = ""
            "country" = ""
         }
    }
    Mock Invoke-ApiRequest { $response }        
    $rootPath = "/authorize/scim/v2/Organizations"

    Context "Create minimal org" {
        # Act
        $added = Add-Org -ParentOrg $parentOrgObject -Name "foo"        
        # Assert
        Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
            $Path -eq $rootPath -and `
            $Version -eq 2 -and `
            $Method -eq "Post" -and `
            ($MatchBody, $Body | Test-Equality)
        }
        $added | Should -Be $response
    }
    Context "parameters" {       
        It "support parent org from pipeline " {
            $added =  $parentOrgObject | Add-Org -Name "foo"        
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 2 -and `
                $Method -eq "Post" -and `
                ($MatchBody, $Body | Test-Equality)
            }
            $added | Should -Be $response
        }        
        It "ensures 'ParentOrg' is not null" {
            {Add-Org -ParentOrg $null } | Should -Throw "Cannot validate argument on parameter 'ParentOrg'. The argument is null or empty"
        }
        It "ensures 'Name' is not null" {
            {Add-Org -ParentOrg $parentOrgObject -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "ensures 'Name' is not empty" {
            {Add-Org -ParentOrg $parentOrgObject -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        $MatchBody.displayName = "displayName"
        $MatchBody.description = "description"
        $MatchBody.externalId = "externalId"
        $MatchBody.type = "type"
        $MatchBody.address.formatted = "address.formatted"
        $MatchBody.address.streetAddress = "address.streetAddress"
        $MatchBody.address.locality = "address.locality"
        $MatchBody.address.region = "address.region"
        $MatchBody.address.postalCode = "address.postalCode"
        $MatchBody.address.country = "address.country"

        It "supports all by name" {
            $added = Add-Org -ParentOrg $parentOrgObject -Name "foo" -DisplayName "displayName" -Description "description" `
                -AddressFormated "address.formatted" -StreetAddress "address.streetAddress" `
                -Locality "address.locality" -Region "address.region" -PostalCode "address.postalCode" `
                -Country "address.country" -ExternalId "externalId" -Type "type"
            
            # Assert
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 2 -and `
                $Method -eq "Post" -and `
                ($MatchBody, $Body | Test-Equality)
            }
            $added | Should -Be $response
        }
        It "support all by position" {       
            $added = Add-Org $parentOrgObject "foo" "displayName" "description" `
                "address.formatted" "address.streetAddress" `
                "address.locality" "address.region" "address.postalCode" `
                "address.country" "externalId" "type"
            
            # Assert
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                $Version -eq 2 -and `
                $Method -eq "Post" -and `
                ($MatchBody, $Body | Test-Equality)
            }
            $added | Should -Be $response    
        }
    }
}