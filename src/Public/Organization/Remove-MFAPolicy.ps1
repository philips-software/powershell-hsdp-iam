<#
    .SYNOPSIS
    Deletes a MFA policy.

    .DESCRIPTION
    Deletes the specified MFA policy resource. A OAuth2.0 Bearer token of a subject with
    HSDP_IAM_MFA_POLICY.UPDATE permission is required to perform only this operation.

    .INPUTS
    The MFA Policy object.

    .OUTPUTS
    An updated MFA Policy PSObject

    .PARAMETER MFAPolicy
    The MFA Policy object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Authentication%20Policy/delete_MFAPolicies__id_

    .EXAMPLE
    # using id of first mfa policy on this org, get the policy object
    $p = Get-MFAPolicy (Get-Org "d578177f-f3db-4919-805a-b382c6fa0032" -IncludePolicies).policies[0].value
    Remove-MFAPolicy $p

    .NOTES
    DELETE: /MFAPolicies/{id} v2
#>
function Remove-MFAPolicy {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
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
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            (Invoke-ApiRequest -Path "/authorize/scim/v2/MFAPolicies/$($Policy.id)" -Version 2 -Method Delete -ValidStatusCodes @(204) )
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}