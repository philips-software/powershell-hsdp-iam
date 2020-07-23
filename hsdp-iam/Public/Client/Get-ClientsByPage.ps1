<#
    .SYNOPSIS
    Retrieves clients by page number

    .DESCRIPTION
    Retrieves client(s) based on a set of parameters in order to either check certain values or to change (some) values
    of this resource and PUT the resource back to the API. Users with the role permission "CLIENT.READ" assigned to the
    manufacturing/producing organization role can read the client information paired to an application that is part of
    the manufacturing/producing organization.

    .INPUTS
    The search parameters

    .OUTPUTS
    Array of client resource objects

    .PARAMETER Id
    An client Id to filter the list of clients

    .PARAMETER ClientId
    An user supplied client Id to filter the list of clients

    .PARAMETER Name
    An name to filter the list of clients

    .PARAMETER Disabled
    Indicates to only fetch disabled client

    .PARAMETER Application
    An application resource object to filter the list of related clients

    .PARAMETER GlobalReferenceId
    An GlobalReferenceId to filter the list of clients

    .PARAMETER Page
    The page number to retrieve

    .PARAMETER Size
    The number of records on the page

    .EXAMPLE
    $firstTwoClients = Get-ClientsByPage -Page 1 -Size 2

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/client-api#/Client/get_authorize_identity_Client

    .NOTES
    GET: /authorize/identity/Client v1
#>
function Get-ClientsByPage {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory=$false, Position = 0, ValueFromPipeline)]
        [String]$Id,

        [Parameter(Mandatory=$false, Position = 1)]
        [ValidateLength(5, 20)]
        [String]$ClientId,

        [Parameter(Mandatory=$false, Position = 3)]
        [ValidateLength(5, 50)]
        [String]$Name,

        [Parameter(Mandatory=$false, Position = 4)]
        [Switch]$Disabled,

        [Parameter(Mandatory=$false, Position = 5)]
        [PSObject]$Application,

        [Parameter(Mandatory=$false, Position = 6)]
        [ValidateLength(3, 50)]
        [String]$GlobalReferenceId,

        [Parameter(Mandatory=$false, Position = 7)]
        [int]$Page = 1,

        [Parameter(Mandatory=$false, Position = 8)]
        [int]$Size = 100
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $path = "/authorize/identity/Client?"
        $add = ""

        if ($PSBoundParameters.ContainsKey('Id')) {
            $add += "_id=$($Id)"
        }
        if ($PSBoundParameters.ContainsKey('ClientId')) {
            if ($add.length) { $add += "&" }
            $add += "clientId=$($ClientId)"
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            if ($add.length) { $add += "&" }
            $add += "name=$($Name)"
        }
        if ($add.length) { $add += "&" }
        $add += "disabled=$($Disabled.ToString().tolower())"
        if ($PSBoundParameters.ContainsKey('Application')) {
            if ($add.length) { $add += "&" }
            $add += "applicationId=$($Application.id)"
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            if ($add.length) { $add += "&" }
            $add += "globalReferenceId=$($GlobalReferenceId)"
        }
        $path += $add + "&_count=$($Size)&_page=$($Page)"

        Write-Output (Invoke-GetRequest -Path $path -Version 1 -ValidStatusCodes @(200))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}