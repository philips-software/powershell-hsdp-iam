<#
    .SYNOPSIS
    Changes a users password in the case of password expiration or a change is needed. See Set-UserPassword in the case
    of new user registration or forgot password flows.

    .DESCRIPTION
    This API is called to set a new password in case of password expiration or if a user wants to change his or her password.
    The inputs are user loginId, the old password, and the new password. The new password will be set only after verification
    of the old password. The account will be in an active/enabled state for this operation.

    Nothing about the correctness/existence of an loginId/email ID and currentPassword should be revealed in the OperationOutcome,
    response messages, or http status code.

    The API supports password history, as users cannot enter their past 5 successful passwords.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .PARAMETER OldPassword
    The old password

    .PARAMETER NewPassword
    The new password

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api#/Password%20Management/post_authorize_identity_User__change_password

    .EXAMPLE
    $user = Get-User -Id "04cc5c04-e67b-46ce-8957-79ecfc66e248"
    New-UserPassword -User $user -OldPassword "P@assword2"m -NewPassword "P@assword3"

    .NOTES
    POST: /authorize/identity/User/$change-password v1
#>
function New-UserPassword {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$User,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]$OldPassword,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$NewPassword,

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
                resourceType = "Parameters";
                "parameter"=@(
                    @{
                    name = "changePassword";
                    resource = @{
                        loginId = $User.loginId;
                        newPassword = $NewPassword;
                        oldPassword = $OldPassword;
                    }
                    }
                )
            }
        }
        Invoke-ApiRequest -Path "/authorize/identity/User/`$change-password" -Version 1 -Method "Post" -AddHsdpApiSignature -Body $Body -ValidStatusCodes @(200) | Out-Null
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}