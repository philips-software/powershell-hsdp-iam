<#
    .SYNOPSIS
    Changes a users password in the case of password expiration or a change is needed. See Set-UserPassword in the case
    of new user registration or forgot password flows.

    .DESCRIPTION
    The input for this API is the user loginId provided during registration. When a user registers, an activation link is
    triggered and is sent to the user's email ID. By default, the user has to click on the "Verify and activate" button in
    the e-mail received, which has a link that is valid for 72 hours. The account has to be activated within this time period
    else the account will be purged unless another recent activation is triggered.

    While in the inactive state, users can request the activation mail to be resent. If user requests a new activation mail,
    a new confirmation code is generated and a new link is emailed to the user, and any old confirmation codes are invalidated.
    The user must then verify the new confirmation code.

    To avoid account enumeration attacks, the same message will be displayed whether or not the user exists. If the user is
    already active, an email explaining that user is active will be sent to the user email ID.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api#/User%20Management/post_authorize_identity_User__resend_activation

    .EXAMPLE
    $User = Get-User -Id 151f128c-e08c-4837-837b-ad0b2ad2e872
    New-UserResendActivation -User $User

    .NOTES
    POST: /authorize/identity/User/$resend-activation v1
#>
function New-UserResendActivation {

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
            $Body = @{
                resourceType = "Parameters";
                "parameter"=@(
                    @{
                        name = "resendOTP";
                        resource = @{
                            loginId = $User.loginId;
                        }
                    }
                )
            }
            Invoke-ApiRequest -Path "/authorize/identity/User/`$resend-activation" -Version 1 -Method "Post" -AddHsdpApiSignature -Body $Body -ValidStatusCodes @(200,202) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}