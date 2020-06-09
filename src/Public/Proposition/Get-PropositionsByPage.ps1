<#
    .SYNOPSIS
    Retrieve propositions by page number

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

    .PARAMETER Page
    The page number based on the Size requested

    .PARAMETER Size
    The maximum number of resource to return in a page

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/proposition-api#/Proposition/get_authorize_identity_Proposition

    .EXAMPLE
    $twoPropositions = Get-PropositionsByPage -Page 1 -Size 2

    .NOTES
    GET: /authorize/identity/Proposition v1
#>
function Get-PropositionsByPage {

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
        [String]$GlobalReferenceId,

        [Parameter(Mandatory=$false, Position = 4)]
        [int]$Page = 1,

        [Parameter(Mandatory=$false, Position = 5)]
        [int]$Size = 100
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/authorize/identity/Proposition?"
        $add = ""
        if ($PSBoundParameters.ContainsKey('Id')) {
            $add += "_id=$($Id)"
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            if ($add.length) { $add += "&" }
            $add += "name=$($Name)"
        }
        if ($PSBoundParameters.ContainsKey('Organization')) {
            if ($add.length) { $add += "&" }
            $add += "organizationId=$($Organization.Id)"
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            if ($add.length) { $add += "&" }
            $add += "globalReferenceId=$($GlobalReferenceId)"
        }
        $path += $add + "&_count=$($Size)&_page=$($Page)"

        Write-Output (Invoke-GetRequest $path -Version 1 -ValidStatusCodes @(200) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}