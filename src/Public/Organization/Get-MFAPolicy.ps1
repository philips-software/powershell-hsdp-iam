<#
    .SYNOPSIS
    Retrieve an existing MFA policy.

    .DESCRIPTION
    Returns the specified MFA policy resource. A OAuth2.0 Bearer token of a subject with HSDP_IAM_MFA_POLICY.READ permission
    is required to perform only this operation.

    .INPUTS
    The policy id

    .OUTPUTS
    And MFA Policy as a PSObject

    .PARAMETER Id
    The MFA Policy identifier

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Authentication%20Policy/get_MFAPolicies__id_

    .EXAMPLE
    $p = Get-MFAPolicy "02bdfa45-db4b-4450-a77e-b59ab9df9472"

    .NOTES
    GET: /MFAPolicies/{id} v2
#>
function Get-MFAPolicy {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [String]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/authorize/scim/v2/MFAPolicies/$($Id)" -Version 2 -ValidStatusCodes @(200) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}