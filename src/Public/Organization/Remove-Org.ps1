<#
    .SYNOPSIS
    Deletes an Organization

    .DESCRIPTION
    Deletes an existing organization. A OAuth2.0 Bearer token of a subject with HSDP_IAM_ORGANIZATION.DELETE permission is required to perform only this operation.
    WARNING: This operation will do hard delete of the requested organization and all its associated resources like users, groups, roles etc. Upon successful
    process of this operation, all dependent resources of the organization will be permanently deleted from the system. All identity access controls to any
    applications associated with deleting organization will be revoked. This operation will also revoke any access to external organization resources from
    the identities belonging to the deleting organization.

    .INPUTS
    The organization object

    .OUTPUTS
    None

    .PARAMETER Org
    The organization object

    .PARAMETER WaitComplete
    Indicates that the operation should wait until it has completed

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Organization/delete_Organizations__id_

    .EXAMPLE
    Get-Org -Id "c1825b0f-f043-499c-9e40-0b6976003393" | Remove-Org

    .NOTES
    DELETE: /Organizations/{id} v2
#>
function Remove-Org {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Position = 1)]
        [Switch]$WaitComplete,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            Invoke-ApiRequest -Path "/authorize/scim/v2/Organizations/$($Org.Id)" -AdditionalHeaders @{"If-Method"="DELETE"} -Version 2 -Method Delete -ValidStatusCodes @(202)
            if ($WaitComplete) {
                Wait-Action -Timeout 300 -RetryInterval 5 -Condition { "IN_PROGRESS" -ne (Get-OrgRemoveStatus -Org $Org) }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}