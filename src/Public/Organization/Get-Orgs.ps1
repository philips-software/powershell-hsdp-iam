<#
    .SYNOPSIS
    Search organizations based on filter criteria.

    .DESCRIPTION
    Retrieves all organizations registered under a specific parent organization. The parent organization can be passed as filter parameter. 
    If no filter is passed, this API will return all child organizations under the requester's organization. A OAuth2.0 Bearer token of 
    a subject with HSDP_IAM_ORGANIZATION.READ permission is required to perform only this operation.

    A maximum of 100 organizations will be returned if pagination options are not set in the request. A partial representation of
    the resource can be requested by specifying either of the mutually exclusive query parameters attributes or excludedAttributes. 
    Search response will not contain policies and $ref for any of the references.

    .OUTPUTS
    Array of organization PSObjects

    .PARAMETER MyOrgOnly
    Specifies to retrieve the current user's org

    .PARAMETER Filter
    An HSDP filter string. (See HSDP documentation)

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/get_Organizations

    .EXAMPLE
    Get-Orgs | Select-Object -First 1

    .EXAMPLE
    Get-Orgs -MyOrgOnly

    .EXAMPLE
    Get-Orgs -Filter "parent.value eq ""e5550a19-b6d9-4a9b-ac3c-10ba817776d4"""

    .NOTES
    GET: /Organizations v2
    Only the first 10000 organizations will be returned.
#>
function Get-Orgs {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Switch]
        [Parameter(Mandatory=$false)]
        $MyOrgOnly,

        [String]
        [Parameter(Mandatory=$false)]
        $Filter
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $url = "/authorize/scim/v2/Organizations"
        if ($MyOrgOnly -or $Filter ) {
            $url += "?"
        }
        if ($MyOrgOnly) {
            $url += "myOrganizationOnly=true"
        }
        if ($MyOrgOnly -and $Filter) { 
            $url += "&"
        }
        if ($Filter) {
            $url += "filter=$($Filter)"
        }
        if ($MyOrgOnly -or $Filter) { 
            $url += "&"
        } else {
            $url += "?"
        }
        $url += "count=10000"
        
        Write-Debug $url
        Write-Output @((Invoke-GetRequest $url -Version 2 -ValidStatusCodes @(200) ).Resources)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}