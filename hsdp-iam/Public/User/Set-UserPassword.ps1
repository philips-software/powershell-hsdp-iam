<#
    .SYNOPSIS
    Sets a user password as part of a new user or password recovery flow

    .DESCRIPTION
    The inputs for the $set-password API are loginId, confirmationcode, new password and context. This API can be called at the end of forgot
    password flow or at the end of user creation flow. A context parameter is provided to identify where it got called. At the end of forgot
    password, it just sets the new password provided in the API. At the end of user create, it sets the given new password and activates the user.
    Context parameters can be context=userCreate or context=recoverPassword.

    To prevent account enumeration attacks, in cases where the given confirmation code and the loginID do not make a valid combination,
    a 401 code wiill be returned with an abstract message so that hacker can not determine whether or not the account exists. The correctness/existence
    of the given emailID is not revealed in the call output.

    .INPUTS
    The user resource object

    .OUTPUTS
    Nothing

    .PARAMETER User
    The user resource object

    .PARAMETER Context
    The context of the set password (userCreate/recoverPassword)

    .PARAMETER ConfirmationCode
    The confirmation code recieved in the email. See email link. Url will contain 'code=<code>'

    .PARAMETER NewPassword
    The new password

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/organization-api-v2#/Authentication%20Policy/put_MFAPolicies__id_

    .EXAMPLE
    $user = Get-User -Id "04cc5c04-e67b-46ce-8957-79ecfc66e248"
    Set-UserPassword -User $user -Context "userCreate" -ConfirmationCode "6WQHCzcr" -NewPassword "P@ssw0rd2"

    .NOTES
    POST: /authorize/identity/User/$set-password v2
#>
function Set-UserPassword {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingUsernameAndPasswordParams', '', Justification='needed to collect')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '', Justification='needed to collect')]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$User,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateSet('userCreate','recoverPassword')]
        [String]$Context,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [String]$ConfirmationCode,

        [Parameter(Mandatory = $true, Position = 3)]
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
                    name = "setPassword";
                    resource = @{
                      loginId = $User.loginId;
                      confirmationCode = $ConfirmationCode;
                      newPassword = $NewPassword;
                      context = $Context;
                    }
                  }
                )
            }
            Invoke-ApiRequest -Path "/authorize/identity/User/`$set-password" -Version 2 -Method "Post" -AddHsdpApiSignature -Body $Body -ValidStatusCodes @(200) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}