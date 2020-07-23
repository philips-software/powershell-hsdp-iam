<#
    .SYNOPSIS
    Retrieve an existing organization.

    .DESCRIPTION
    Returns the specified organization resource. A OAuth2.0 Bearer token of a subject with HSDP_IAM_ORGANIZATION.READ permission
    is required to perform only this operation. Response will not contain policies unless explicitly requested using includePolicies
    query parameter.

    A partial representation of the resource can be requested by specifying either of the mutually exclusive query parameters
    attributes or excludedAttributes.

    .INPUTS
    The organization identifier

    .OUTPUTS
    The organization resource object

    .PARAMETER Id
    The organization identifier

    .PARAMETER IncludePolicies
    Indicates if policies for the organization should be included

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/get_Organizations__id_

    .EXAMPLE
    Get-Org "02bdfa45-db4b-4450-a77e-b59ab9df9472"

    .EXAMPLE
    "02bdfa45-db4b-4450-a77e-b59ab9df9472" | Get-Org -IncludePolicies

    .NOTES
    GET: /Organizations/{id} v2
#>
function Get-Org {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [String]$Id,

        [Switch]
        [Parameter(Mandatory=$false)]
        $IncludePolicies
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/authorize/scim/v2/Organizations/$($Id)?includePolicies=$($IncludePolicies)" -Version 2 -ValidStatusCodes @(200,201) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}