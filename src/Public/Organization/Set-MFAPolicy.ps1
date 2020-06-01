<#
    .SYNOPSIS
    Modify a MFA policy resource properties.

    .DESCRIPTION
    Updates an existing MFA policy resource attributes. It is advised to pass the entire resource object while performing
    an update. The readOnly attributes will be ignored even if it is not matching with the actual resource. A OAuth2.0
    Bearer token of a subject with HSDP_IAM_MFA_POLICY.UPDATE permission is required to perform only this operation.

    NOTE: The following readWrite attributes will NOT be allowed to update currently - resource.type, resource.value

    .INPUTS
    The MFA Policy PSObject

    .OUTPUTS
    An updated MFA Policy PSObject

    .PARAMETER Policy
    The MFA Policy PSObject

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Authentication%20Policy/put_MFAPolicies__id_

    .EXAMPLE
    $p = Get-MFAPolicy (Get-Org "d578177f-f3db-4919-805a-b382c6fa0032" -IncludePolicies).policies[0].value
    $p.description = "new description"
    $p = Set-MFAPolicy $p

    .NOTES
    PUT: /MFAPolicies/{id} v2
#>
function Set-MFAPolicy {

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
            Write-Output @((Invoke-ApiRequest "/authorize/scim/v2/MFAPolicies/$($Policy.id)" -Method Put -AddIfMatch -Body $Policy -Version 2 -ValidStatusCodes @(200)))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}