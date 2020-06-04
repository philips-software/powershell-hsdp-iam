<#
    .SYNOPSIS
    Retrieves Proposition based on an identifier

    .DESCRIPTION
    Retrieves Proposition(s) based on a set of parameters in order to either check certain values,
    or to change (some) values of this resource and PUT the resource back to the API. A user with
    PROPOSITION.READ permissions assigned to the organization role can retrieve propositions under
    the organization. The organization ID or ID is mandatory for retrieval.

    .INPUTS
    A proposition identifier

    .OUTPUTS
    An Proposition PSObject

    .PARAMETER Id
    A proposition identifier

    .EXAMPLE
    $proposition = Get-Proposition -Id "303d50fd-557d-42c6-963d-6788c02d689a"

    .LINK
    https://www.hsdp.io/docume@ntation/identity-and-access-management-iam/api-documents/resource-reference-api/proposition-api#/Proposition/get_authorize_identity_Proposition

    .NOTES
    GET: /authorize/identity/Proposition v1
#>
function Get-Proposition {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # TODO: Support all query parameters (not just Id)
        $response = (Invoke-GetRequest "/authorize/identity/Proposition?_id=$($Id)" -Version 1 -ValidStatusCodes @(200) )
        Write-Output $response.entry
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}