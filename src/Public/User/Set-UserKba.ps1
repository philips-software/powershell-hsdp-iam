<#
    .SYNOPSIS
    Save challenge questions and answers selected by the user

    .DESCRIPTION
    This API saves given set of questions and answers selected by a user. In a typical UI workflow, this will be
    used while completing registration or after setting password. This is a self-service API; a given user's access
    token will permit the user's kba to be set. Alternately, USER.WRITE permission allows to set user's kba. The payload
    submitted must match restrictions set by the minQuestionCount attribute for kba at organization level.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .PARAMETER User
    The user resource object

    .PARAMETER User
    The user resource object

    .PARAMETER ChallengeResponses
    A hashtable with keys representing challenge questions and the values representing the corresponding responses

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api#/User%20Management/post_authorize_identity_User__id___kba

    .EXAMPLE
    $user = Get-User -Id "mytestuser1"
    Set-UserKba -User $user -ChallengeResponses @{"favorite color"="blue"; "pets name"="fido"}

    .NOTES
    POST: /authorize/identity/User/{id}/$kba v1
#>
function Set-UserKba {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
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
            $Body = @{ challenges = @() }
            $ChallengeResponses.Keys | ForEach-Object {
                $Body.challenges += @{
                    challenge=$_;
                    response=$ChallengeResponses[$_]
                }
            }
            Invoke-ApiRequest -Path "/authorize/identity/User/$($User.Id)/`$kba" -Version 1 -Method "Post" -Body $Body -ValidStatusCodes @(201) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}