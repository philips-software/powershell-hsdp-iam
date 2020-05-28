$source = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$source\Add-Org.ps1"
. "$source\..\Utility\Invoke-ApiRequest.ps1"

Describe "Add-Org" {
    $response = [PSCustomObject]@{ }
    $parentOrgId = "1"
    $parentOrgObject = ([PSCustomObject]@{id = $parentOrgId })
    $MinBody = @{
        "schemas" = @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:Organization");
        "name"    = "foo";
        "parent"  = @{
            "value" = $parentOrgId;
        };
    }
    $FullBody = @{
        "schemas"     = @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:Organization");
        "displayName" = "";
        "name"        = "foo";
        "description" = "";
        "parent"      = @{
            "value" = $parentOrgId;
        };
        "externalId"  = ""
        "type"        = ""
        "address"     = @{
            "formatted"     = ""
            "streetAddress" = ""
            "locality"      = ""
            "region"        = ""
            "postalCode"    = ""
            "country"       = ""
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
            ($MinBody, $Body | Test-Equality)
        }
        $added | Should -Be $response
    }
    Context "parameters" {       
        It "support parent org from pipeline " {
            $added = $parentOrgObject | Add-Org -Name "foo"        
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                    $Version -eq 2 -and `
                    $Method -eq "Post" -and `
                ($MinBody, $Body | Test-Equality)
            }
            $added | Should -Be $response
        }        
        It "ensures 'ParentOrg' is not null" {
            { Add-Org -ParentOrg $null } | Should -Throw "Cannot validate argument on parameter 'ParentOrg'. The argument is null or empty"
        }
        It "ensures 'Name' is not null" {
            { Add-Org -ParentOrg $parentOrgObject -Name $null } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        It "ensures 'Name' is not empty" {
            { Add-Org -ParentOrg $parentOrgObject -Name "" } | Should -Throw "Cannot validate argument on parameter 'Name'. The argument is null or empty"
        }
        $FullBody.displayName = "displayName"
        $FullBody.description = "description"
        $FullBody.externalId = "externalId"
        $FullBody.type = "type"
        $FullBody.address.formatted = "address.formatted"
        $FullBody.address.streetAddress = "address.streetAddress"
        $FullBody.address.locality = "address.locality"
        $FullBody.address.region = "address.region"
        $FullBody.address.postalCode = "address.postalCode"
        $FullBody.address.country = "address.country"

        It "supports -DisplayName" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -DisplayName "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.displayName -eq "x" }
        }
        It "supports -Description" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Description "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.description -eq "x" }
        }
        It "supports -Type" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Type "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.type -eq "x" }
        }
        It "supports -ExternalId" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -ExternalId "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.externalId -eq "x" }
        }
        It "supports -AddressFormated" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -AddressFormated "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.address.formatted -eq "x" }
        }
        It "supports -StreetAddress" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -StreetAddress "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.address.streetAddress -eq "x" }
        }
        It "supports -Locality" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Locality "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.address.locality -eq "x" }
        }
        It "supports -Region" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Region "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.address.region -eq "x" }
        }
        It "supports -PostalCode" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -PostalCode "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.address.postalCode -eq "x" }
        }
        It "supports -Country" {
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Country "x"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { $Body.address.country -eq "x" }
        }
        It "support all by position" {
            Add-Org $parentOrgObject "name" "displayName" "description" `
                "address.formatted" "address.streetAddress" `
                "address.locality" "address.region" "address.postalCode" `
                "address.country" "externalId" "type"
            Assert-MockCalled Invoke-ApiRequest -ParameterFilter { 
                $Body.displayName -eq "displayName" `
                    -and $Body.address.formatted -eq "address.formatted"  `
                    -and $Body.address.streetAddress -eq "address.streetAddress"  `
                    -and $Body.address.locality -eq "address.locality"  `
                    -and $Body.address.region -eq "address.region"  `
                    -and $Body.address.postalCode -eq "address.postalCode"  `
                    -and $Body.address.country -eq "address.country"  `
                    -and $Body.externalId -eq "externalId"  `
                    -and $Body.type -eq "type" 
            }
        }
    }
}