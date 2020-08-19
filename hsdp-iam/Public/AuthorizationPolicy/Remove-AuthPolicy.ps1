<#
    .SYNOPSIS
    Removes an auth policy

    .DESCRIPTION
    Removes a registered policy from the policySetId. An OAuth2.0 token is required with POLICY.WRITE permission to do this operation.
    Delete operation will permanently delete the policy from the policySetId.

    .INPUTS
    Accepst the Policy object from the pipeline

    .OUTPUTS
    Nothing if the operation is successful otherwise the opertional result object

    .PARAMETER Policy
    The authorizxation policy object. (Must have a member id containing the policy id)

    .EXAMPLE
    $myPolciy = Get-Policy -Id "bfc10f8b-86dd-4af3-b758-09823df5c4ae"
    Remove-AuthPolicy $myPolicy

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/policy-provisioning-api#/Policy/delete_authorize_access_Policy__id_

    .NOTES
    DELETE: ​/authorize​/access​/Policy v1
#>
function Remove-AuthPolicy {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Policy,

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
            Write-Output (Invoke-ApiRequest -Path "/authorize/access/Policy/$($Policy.Id)" -Version 1 -Method Delete -ValidStatusCodes @(204) )
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}