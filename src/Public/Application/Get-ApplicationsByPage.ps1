<#
    .SYNOPSIS
    Retrieves application resources by page number and count

    .DESCRIPTION
    Retrieves Application(s) based on a set of parameters in order to either check certain values, or to change (some) values of this resource and
    PUT the resource back to the API. A user with APPLICATION.READ permissions assigned to the organization role can retrieve the application under
    the proposition. The ID or propositionId parameter is mandatory for application retrieval.

    .INPUTS
    The search parameters

    .OUTPUTS
    Array of application resource objects

    .PARAMETER Id
    An application Id to filter the list of applications

    .PARAMETER Proposition
    A proposition resource object to filter the list of related applications

    .PARAMETER Name
    An name to filter the list of applications

    .PARAMETER GlobalReferenceId
    An GlobalReferenceId to filter the list of applications

    .PARAMETER Page
    The page number to retrieve

    .PARAMETER Size
    The number of records on the page

    .EXAMPLE
    $firstPageTwoResources = Get-ApplicationsByPage -Page 1 -Size 2

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/application-api#/

    .NOTES
    GET: /authorize/identity/Application v1
#>
function Get-ApplicationsByPage {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, ParameterSetName="Id")]
        [ValidateNotNullOrEmpty()]
        [String]$Id,

        [Parameter(Mandatory, ParameterSetName="Proposition")]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Proposition,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory = $false)]
        [int]$Page = 1,

        [Parameter(Mandatory = $false)]
        [int]$Size = 100
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/authorize/identity/Application"

        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $path += "?_id=$($Id)"
        }
        if ($PSCmdlet.ParameterSetName -eq "Proposition") {
            $path += "?propositionId=$($Proposition.id)"
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            $path += "&name=$($Name)"
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            $path += "&globalReferenceId=$($GlobalReferenceId)"
        }

        $path += "&_count=$($Size)&_page=$($Page)"

        Write-Output (Invoke-GetRequest $path -Version 1 -ValidStatusCodes @(200) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}