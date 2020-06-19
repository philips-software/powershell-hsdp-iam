<#
    .SYNOPSIS
    Modify an client properties

    .DESCRIPTION
    Allows a user to update device information. Any user with DEVICE.WRITE permission within the organization
    can update device properties.

    The entire resource data must be passed as request body to update a device. If read-only attributes
    (such as id, loginId, password, meta, organizationId) are passed, that will be ignored.

    .INPUTS
    The device resource object

    .OUTPUTS
    An updated device resource object

    .PARAMETER Device
    The device resource object to update

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/device-api#/Device%20Management/put_authorize_identity_Device__id_

    .EXAMPLE
    $myDevice = Get-Devices -Id "8e57e67e-3159-4fd4-ae97-4305dfe80db0"
    $myDevice.type = "Apple Watch"
    $myDevice = Set-Device $myDevice

    .NOTES
    PUT: /authorize/identity/Device v1
#>
function Set-Device {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
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
            Write-Output @((Invoke-ApiRequest "/authorize/identity/Device/$($Device.Id)" -Method Put -Body $Device -Version 1 -ValidStatusCodes @(200)))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}