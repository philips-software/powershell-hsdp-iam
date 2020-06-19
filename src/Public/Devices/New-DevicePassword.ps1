<#
    .SYNOPSIS
    Change device identity password

    .DESCRIPTION
    Allows device to change the password using its own access token. No password history will be maintained for device.
    Password Requirements:
    - Should be a minimum length of eight (8) characters
    - At least one uppercase letter should be present
    - At least one lowercase letter should be present
    - At least one number should be present
    - At least one special character should be present (_, -, +, =, !, @, %, *, &, ”, :, ., or $)

    .INPUTS
    Accepts a device resource object

    .OUTPUTS
    Nothing

    .EXAMPLE

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/device-api#/Device%20Management/post_authorize_identity_Device__id___change_password

    .NOTES
    POST: /authorize/identity/Device/{id}/$change-password v1
#>
function New-DevicePassword {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]$Device,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [String]$Old,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateLength(8, 255)]
        [String]$New,

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
            $Body = @{
                oldPassword = $Old;
                newPassword = $New;
            }
            Invoke-ApiRequest -ReturnResponseHeader -Path "/authorize/identity/Device/$($Device.Id)/`$change-password" -Version 1 -Method Post -Body $body -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}