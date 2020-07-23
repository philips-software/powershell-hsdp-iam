<#
    .SYNOPSIS
    Retrieves clients

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

    .EXAMPLE
    $allClients = Get-Clients

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/client-api#/Client/get_authorize_identity_Client

    .NOTES
    GET: /authorize/identity/Client v1
#>
function Get-Clients {

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
        if ($PSBoundParameters.ContainsKey('ClientId')) {
            $p.ClientId = $ClientId
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            $p.Name = $Name
        }
        if ($Disabled) {
            $p.Disabled = $true
        }
        if ($PSBoundParameters.ContainsKey('Application')) {
            $p.Application = $Application
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            $p.GlobalReferenceId = $GlobalReferenceId
        }
        do {
            Write-Verbose "Page # $($p.Page)"
            $response = Get-ClientsByPage @p
            Write-Output $response.entry
            $p.Page += 1
        } while (($response.total -eq $p.Size))

    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}