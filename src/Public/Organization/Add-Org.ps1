<#
    .SYNOPSIS
    Creates a new organization account.

    .DESCRIPTION
    Creates an organization account. An OAuth2.0 Bearer token of a subject with HSDP_IAM_ORGANIZATION.CREATE permission is required to 
    perform only this operation.
    
    If a parent organization is specified in the request, the new organization will be created under the specified parent organization. 
    Otherwise, the new organization will be created under the requester organization. The provisioning logic for all possible combinations
     is as follows:

    Parent Organization	    New Organization Level
    PROVIDED	            As CHILD of parent organization
    X	                    As CHILD of requester organization

    .INPUTS
    The Parent organization PSObject

    .OUTPUTS
    The added Organization as a PSObject

    .PARAMETER ParentOrg
    The parent org object to associate

    .PARAMETER Name
    The name of the organization

    .PARAMETER DisplayName
    The displayed name of the organization

    .Parameter Description
    The description of the organization

    .PARAMETER AddressFormated
    The address of the organization

    .PARAMETER StreetAddress
    The street address of the organization
    
    .PARAMETER Locality
    The locality of the organization

    .PARAMETER Region
    The region of the organization

    .PARAMETER PostalCode
    The postal code of the organization
    
    .PARAMETER Country
    The country of the organization

    .PARAMETER ExternalId
    An user definable identifer to track the organization from another system.

    .PARAMETER Type
    The type (e.g. Hospital) of the organization
        
    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/post_Organizations

    .EXAMPLE
    $parentOrg = Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"
    $newOrg = Add-Org -ParentOrg $parentOrg -Name "MyNewOrg"

    .NOTES
    POST: /Organizations v2
#>
function Add-Org {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$ParentOrg,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $false, Position = 2)]
        [String]$DisplayName,

        [Parameter(Mandatory = $false, Position = 3)]
        [String]$Description,

        [Parameter(Mandatory = $false, Position = 4)]
        [String]$AddressFormated,

        [Parameter(Mandatory = $false, Position = 5)]
        [String]$StreetAddress,

        [Parameter(Mandatory = $false, Position = 6)]
        [String]$Locality,

        [Parameter(Mandatory = $false, Position = 7)]
        [String]$Region,

        [Parameter(Mandatory = $false, Position = 8)]
        [String]$PostalCode,

        [Parameter(Mandatory = $false, Position = 9)]
        [String]$Country,

        [Parameter(Mandatory = $false, Position = 10)]
        [String]$ExternalId,

        [Parameter(Mandatory = $false, Position = 11)]
        [String]$Type
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $Org = @{
            "schemas"= @("urn:ietf:params:scim:schemas:core:philips:hsdp:2.0:Organization");
            "displayName" = $DisplayName
            "name" = $Name;
            "description" = $Description;
            "parent" = @{
                "value" = $ParentOrg.id;
             };
             "externalId" = $ExternalId;
             "type"= $Type;
             "address" = @{
                "formatted" = $AddressFormated;
                "streetAddress" = $StreetAddress;
                "locality" = $Locality;
                "region" = $Region;
                "postalCode" = $PostalCode;
                "country" = $Country;
             }
        }
        (Invoke-ApiRequest -Path "/authorize/scim/v2/Organizations" -Version 2 -Method Post -Body $Org -ValidStatusCodes @(201) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}