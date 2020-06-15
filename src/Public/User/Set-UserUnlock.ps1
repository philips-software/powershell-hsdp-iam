<#
    .SYNOPSIS
    Unlocks a locked user account

    .DESCRIPTION
    Allows an administrator to unlock a user account if the user account is locked due to invalid login attempts.
    USER.WRITE permission is required to do this operation.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api#/User%20Management/post_authorize_identity_User__id___unlock

    .EXAMPLE
    (Get-User -Id "04cc5c04-e67b-46ce-8957-79ecfc66e248") | Set-UserUnlock

    .NOTES
    POST: /authorize/identity/User/{id}/$unlock v1
#>
function Set-UserUnlock {

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
            Invoke-ApiRequest -Path "/authorize/identity/User/$($User.Id)/`$unlock" -Version 1 -Method "Post" -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}