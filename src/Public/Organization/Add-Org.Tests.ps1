Set-StrictMode -Version Latest

BeforeAll {        
    . "$PSScriptRoot\Add-Org.ps1"
    . "$PSScriptRoot\..\Utility\Invoke-ApiRequest.ps1"
}

Describe "Add-Org" {
    BeforeAll {
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
        $rootPath = "/authorize/scim/v2/Organizations"
        Mock Invoke-ApiRequest { $response }
    }
    Context "api" {
        It "invokes request" {
            $added = Add-Org -ParentOrg $parentOrgObject -Name "foo"        
            $added | Should -Be $response  
            Should -Invoke Invoke-ApiRequest -ParameterFilter {
                $Path -eq $rootPath -and `
                    $Version -eq 2 -and `
                    $Method -eq "Post" -and `
                ($MinBody, $Body | Test-Equality)
            }
        }
    }
    Context "param" {
        It "value from pipeline " {
            $added = $parentOrgObject | Add-Org -Name "foo"        
            Should -Invoke Invoke-ApiRequest
            $added | Should -Be $response
        }        
        It "ensures -ParentOrg not null" {
            { Add-Org -ParentOrg $null } | Should -Throw "*'ParentOrg'. The argument is null or empty*"
        }
        It "ensures -Name not null" {
            { Add-Org -ParentOrg $parentOrgObject -Name $null } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "ensures -Name not empty" {
            { Add-Org -ParentOrg $parentOrgObject -Name "" } | Should -Throw "*'Name'. The argument is null or empty*"
        }
        It "supports -DisplayName" {
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
            Mock Invoke-ApiRequest -ParameterFilter { $Body.displayName -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -DisplayName "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -Description" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.description -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Description "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -Type" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.type -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Type "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -ExternalId" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.externalId -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -ExternalId "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -AddressFormated" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.address.formatted -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -AddressFormated "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -StreetAddress" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.address.streetAddress -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -StreetAddress "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -Locality" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.address.locality -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Locality "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -Region" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.address.region -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Region "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -PostalCode" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.address.postalCode -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -PostalCode "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports -Country" {
            Mock Invoke-ApiRequest -ParameterFilter { $Body.address.country -eq "x" }
            Add-Org -ParentOrg $parentOrgObject -Name "a" -Country "x"
            Should -Invoke Invoke-ApiRequest
        }
        It "supports by position" {
            Mock Invoke-ApiRequest { $response } -ParameterFilter {
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
            Add-Org $parentOrgObject "name" "displayName" "description" `
                "address.formatted" "address.streetAddress" `
                "address.locality" "address.region" "address.postalCode" `
                "address.country" "externalId" "type"
            Should -Invoke Invoke-ApiRequest
        }
    }
}