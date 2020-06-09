<#
    .SYNOPSIS
    Retrieve propositions

    .DESCRIPTION
    Retrieves Proposition(s) based on a set of parameters in order to either check certain values, or to change (some) values of this
    resource and PUT the resource back to the API. A user with PROPOSITION.READ permissions assigned to the organization role can retrieve
    propositions under the organization. The organization ID or ID is mandatory for retrieval.

    .INPUTS
    The proposition identifier

    .OUTPUTS
    An array of proposition resource objects

    .PARAMETER Id
    The proposition identifier

    .PARAMETER Name
    The name of the poposition

    .PARAMETER Organization
    The organization resource object that propositions belong to

    .PARAMETER GlobalReferenceId
    The global reference id

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/proposition-api#/Proposition/get_authorize_identity_Proposition

    .EXAMPLE
    $allPropositions = Get-Propositions

    .NOTES
    GET: /authorize/identity/Proposition v1
#>
function Get-Propositions {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$false, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$Id,

        [Parameter(Mandatory=$false, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory=$false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Organization,

        [Parameter(Mandatory=$false, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [String]$GlobalReferenceId
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $p = @{ Page = 1; Size = 100}
        if ($PSBoundParameters.ContainsKey('Id')) {
            $p.Id = $Id
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            $p.Name = $Name
        }
        if ($PSBoundParameters.ContainsKey('Organization')) {
            $p.Organization = $Organization
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            $p.GlobalReferenceId = $GlobalReferenceId
        }
        do {
            Write-Verbose "Page # $($p.Page)"
            $response = Get-PropositionsByPage @p
            Write-Output $response.entry
            $p.Page += 1
        } while (($response.total -eq $p.Size))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}