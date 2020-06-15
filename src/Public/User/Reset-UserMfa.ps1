<#
    .SYNOPSIS
    Unlocks a locked user account

    .DESCRIPTION
    Resets the device key registered for the user. This allows user to re-register a new device to generate soft OTP for
    multi-factor authentication. An OAuth2 Bearer token is required to do this operation. Self user with no permission
    or any user with ORGANIZATION.MFA permission within the organization can do this operation.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api-v2#/Management/post_authorize_identity_User__id___mfa_reset

    .EXAMPLE
    $user = Get-User -Id "myuser@mailinator.com"
    $user | Reset-UserMfa

    .NOTES
    POST: /authorize/identity/User/{id}/$mfa-reset v1
#>
function Reset-UserMfa {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$User,

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
            $Body = @{ action = "reset" }
            Invoke-ApiRequest -Path "/authorize/identity/User/$($User.Id)/`$mfa-reset" -Version 2 -Method "Post" -Body $Body -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}