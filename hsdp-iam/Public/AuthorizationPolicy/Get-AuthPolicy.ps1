<#
    .SYNOPSIS
    Gets a policy object by id

    .DESCRIPTION
    Returns the specified policy details. An OAuth2.0 token is required with permission POLICY.WRITE to retrieve policy details.

    .INPUTS
    Accepts the Id from the pipeline

    .OUTPUTS
    Returns the policy object

    .PARAMETER Id
    Unique ID of the policy.

    .EXAMPLE
    $policy = Get-AuthPolicy -Id "dbc72a5f-74b0-4e9b-9eb1-70d83fee4783"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/policy-provisioning-api#/Policy/get_authorize_access_Policy__id_

    .NOTES
    GET /authorize/access/Policy/{id} v1
#>
function Get-AuthPolicy {

    [CmdletBinding()]
    [OutputType([PSObject[]])]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/authorize/access/Policy/$($Id)" -Version 1)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}