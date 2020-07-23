<#
    .SYNOPSIS
    Retrieves applications

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

    .EXAMPLE
    $allApps = Get-Applications

    .EXAMPLE
    $app = (Get-Propositions -Name "myprop" | Get-Applications)

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/application-api#/

    .NOTES
    GET: /authorize/identity/Application v1
#>
function Get-Applications {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, ParameterSetName="Proposition", ValueFromPipeline, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Proposition,

        [Parameter(Mandatory, ParameterSetName="Id", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$Id,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$Name,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [String]$GlobalReferenceId
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        $p = @{ Page = 1; Size = 100}
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $p.Id = $Id
        }
        if ($PSCmdlet.ParameterSetName -eq "Proposition") {
            $p.Proposition = $Proposition
        }
        if ($PSBoundParameters.ContainsKey('Name')) {
            $p.Name = $Name
        }
        if ($PSBoundParameters.ContainsKey('GlobalReferenceId')) {
            $p.GlobalReferenceId = $GlobalReferenceId
        }
        do {
            Write-Verbose "Page # $($p.Page)"
            $response = Get-ApplicationsByPage @p
            Write-Output $response.entry
            $p.Page += 1
        } while (($response.total -eq $p.Size))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}