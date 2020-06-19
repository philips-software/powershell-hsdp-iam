<#
    .SYNOPSIS
    Removes a device

    .DESCRIPTION
    Removes a device identity from an organization. The is usually done by a organization administrator.
    Any user with DEVICE.WRITE or DEVICE.DELETE permission within the organization can delete a device
    from an organization.

    .INPUTS
    The device resource object

    .OUTPUTS
    None

    .PARAMETER Device
    The device object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/device-api#/Device%20Management/delete_authorize_identity_Device__id_

    .NOTES
    DELETE: ​/authorize​/identity​/Device/{id} v1
#>
function Remove-Device {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]$Device,

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
            Invoke-ApiRequest -Path "/authorize/identity/Device/$($Device.Id)" -Version 1 -Method Delete -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}