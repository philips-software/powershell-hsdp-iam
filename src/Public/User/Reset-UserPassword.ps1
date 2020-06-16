<#
    .SYNOPSIS
    Reset password service with kba validation

    .DESCRIPTION
    This API triggers password reset flow for a user. This acts as kba verification step before sending the reset
    code through an email or SMS. A private OAuth2.0 client that passes basic authorization header will be able
    to execute this API. If invalid kba information is submitted more than permitted times
    (based on the org's maxIncorrectAttempts), the user account will be locked. If KBA information is valid,
    reset code will be sent using the notificationMode attribute in input. Currently only EMAIL value is supported
    in notificationMode.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .PARAMETER ChallengeResponses
    A hashtable with keys representing challenge questions and the values representing the corresponding responses

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api#/Password%20Management/post_authorize_identity_User__reset_password

    .EXAMPLE
    $user = Get-User -Id "myuser@mailinator.com"
    Reset-UserPassword -User $user -ChallengeResponses @{"color"="blue"}

    .NOTES
    POST: /authorize/identity/User/$reset-password v1
#>
function Reset-UserPassword {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$User,

        [Parameter(Mandatory = $true, Position = 1)]
        [Hashtable]$ChallengeResponses,

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
                loginId = $User.loginId;
                challenges = @()
            }
            $ChallengeResponses.Keys | ForEach-Object {
                $Body.challenges += @{
                    challenge=$_;
                    response=$ChallengeResponses[$_]
                }
            }
            Invoke-ApiRequest -Path "/authorize/identity/User/`$reset-password" -Version 1 -Method "Post" -Body $Body -ValidStatusCodes @(202) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}