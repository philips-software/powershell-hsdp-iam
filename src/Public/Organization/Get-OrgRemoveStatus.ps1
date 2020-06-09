<#
    .SYNOPSIS
    Getst the status of the organization removal status.

    .DESCRIPTION
    Returns the delete status of a specified organization resource. A OAuth2.0 Bearer token of a subject with HSDP_IAM_ORGANIZATION.DELETE permission is required to perform only this operation.

    .INPUTS
    The organization resource object

    .OUTPUTS
    The status of the deletion request for the organization

    .PARAMETER Org
    The organization resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/get_Organizations__id__deleteStatus

    .EXAMPLE
    Get-OrgDeleteStatus -Org $org

    .NOTES
    GET: /authorize/scim/v2/Organizations/{id}/deleteStatus v2
#>
function Get-OrgRemoveStatus {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [PSObject]$Org
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest "/authorize/scim/v2/Organizations/$($Org.id)/deleteStatus" -Version 2 -ValidStatusCodes @(200)).status
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}