<#
    .SYNOPSIS
    Create a password policy

    .DESCRIPTION
    Provision a new password policy under an organization. A user with PASSWORDPOLICY.WRITE can provision a
    policy in the system.

    NOTE:
    Only one password policy can be created under an organization. This API will fail with 409 Conflict,
    if a password policy already exists within the organization. Minimum of one parameter
    (expiry period in days or history count or challenge policy or complexity)
    is required to create a password policy.

    .INPUTS
    The organization resource object

    .OUTPUTS
    The new policy object

    .PARAMETER Org
    The organizational resource object

    .PARAMETER ExpiryPeriodInDays
    The number of days after which the user's password expires. The user must set a new password after it expires.

    .PARAMETER HistoryCount
    The number of previous passwords that cannot be used as new password.

    .PARAMETER MinLength
    The minimum number of characters password can contain.

    .PARAMETER MaxLength
    The maximum number of characters password can contain.

    .PARAMETER MinNumerics
    The minimum number of numerical characters password can contain.

    .PARAMETER MinUpperCase
    The minimum number of uppercase characters password can contain.

    .PARAMETER MinLowerCase
    The minimum number of lower characters password can contain.

    .PARAMETER MinSpecialChars
    The minimum number of special characters password can contain.

    .PARAMETER ChallengesEnabled
    Enable challenges at organization level. If the set then the DefaultQuestions parameter is mandatory.

    .PARAMETER DefaultQuestions
    An array of String values that contains default question(s) a user may use when setting their challenge questions.

    .PARAMETER MinQuestionCount
    The minimum number of challenge questions a user MUST answer when setting challenge question answers.
    MinQuestionCount cannot be greater than the number of default questions.

    .PARAMETER MinAnswerCount
    The minimum number of challenge answers a user MUST answer when attempting to reset their password.
    MinAnswerCount cannot be greater than minQuestionCount.

    .PARAMETER MaxIncorrectAttempts
    An Integer indicates the maximum number of failed reset password attempts using challenges.
    Failed attempts beyond this will cause account lockout for 30 mins.

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/password-api#/Password%20Policy/post_authorize_identity_PasswordPolicy

    .EXAMPLE

    .NOTES
    POST: /authorize/identity/PasswordPolicy v1
#>
function Add-PasswordPolicy {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Org,

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidateRange(1, 1095)]
        [Int]$ExpiryPeriodInDays = 1095,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidateRange(1, 10)]
        [Int]$HistoryCount = 1,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidateRange(8, 256)]
        [Int]$MinLength = 8,

        [Parameter(Mandatory = $false, Position = 4)]
        [ValidateRange(8, 256)]
        [Int]$MaxLength = 256,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidateRange(0, 256)]
        [Int]$MinNumerics = 0,

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidateRange(0, 256)]
        [Int]$MinUpperCase = 0,

        [Parameter(Mandatory = $false, Position = 7)]
        [ValidateRange(0, 256)]
        [Int]$MinLowerCase = 0,

        [Parameter(Mandatory = $false, Position = 7)]
        [ValidateRange(0, 256)]
        [Int]$MinSpecialChars = 0,

        [Parameter(Mandatory = $false, Position = 9)]
        [Switch]$ChallengesEnabled,

        [Parameter(Mandatory = $false, Position = 10)]
        [String[]]$DefaultQuestions,

        [Parameter(Mandatory = $false, Position = 11)]
        [ValidateRange(1, 5)]
        [Int]$MinQuestionCount,

        [Parameter(Mandatory = $false, Position = 12)]
        [ValidateRange(1, 5)]
        [Int]$MinAnswerCount,

        [Parameter(Mandatory = $false, Position = 13)]
        [ValidateRange(1, 5)]
        [Int]$MaxIncorrectAttempts
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # Param validation rules
        if ($ChallengesEnabled) {
            if (-not $PSBoundParameters.ContainsKey('DefaultQuestions') -or ($DefaultQuestions.Length -eq 0)) {
                throw "Must specify -DefaultQuestions if -ChallengesEnabled"
            }
            if (-not $PSBoundParameters.ContainsKey('MinQuestionCount')) {
                throw "Must specify -MinQuestionCount if -ChallengesEnabled"
            }
            if (-not $PSBoundParameters.ContainsKey('MinAnswerCount')) {
                throw "Must specify -MinAnswerCount if -ChallengesEnabled"
            }
            if (-not $PSBoundParameters.ContainsKey('MaxIncorrectAttempts')) {
                throw "Must specify -MaxIncorrectAttempts if -ChallengesEnabled"
            }
            if ($MinQuestionCount -gt $DefaultQuestions.Length ) {
                throw "-MinQuestionCount must be less than or equal to -DefaultQuestions length"
            }
            if ($MinAnswerCount -gt $MinQuestionCount) {
                throw "-MinAnswerCount must be less or equal to -MinQuestionCount"
            }
        }
        else {
            if ($PSBoundParameters.ContainsKey('MinQuestionCount') -or $PSBoundParameters.ContainsKey('MinAnswerCount') -or $PSBoundParameters.ContainsKey('MaxIncorrectAttempts')) {
                throw "Must specify -ChallengesEnabled if specifying -MinQuestionCount, -MinAnswerCount or -MaxIncorrectAttempts"
            }
        }
        $Body = @{
            managingOrganization = $Org.Id;
            expiryPeriodInDays   = $ExpiryPeriodInDays;
            historyCount         = $HistoryCount;
            complexity           = @{
                minLength       = $MinLength;
                maxLength       = $MaxLength;
                minNumerics     = $MinNumerics;
                minUpperCase    = $MinUpperCase;
                minLowerCase    = $MinLowerCase;
                minSpecialChars = $MinSpecialChars;
            }
        }

        if ($ChallengesEnabled) {
            $Body.challengesEnabled = "true";
            $Body.challengePolicy = @{
                defaultQuestions     = $DefaultQuestions;
                minQuestionCount     = $MinQuestionCount;
                minAnswerCount       = $MinAnswerCount;
                maxIncorrectAttempts = $MaxIncorrectAttempts;
            }
        }
        (Invoke-ApiRequest -Path "/authorize/identity/PasswordPolicy" -Version 1 -Method Post -Body $Body -ValidStatusCodes @(201) )
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}