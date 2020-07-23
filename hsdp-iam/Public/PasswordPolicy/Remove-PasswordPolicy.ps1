<#
    .SYNOPSIS
    Remove a password policy

    .DESCRIPTION
    Removes a password policy from an organization. Any user with PASSWORDPOLICY.WRITE permission can delete the policy.

    .INPUTS
    The policy resource object

    .OUTPUTS
    Nothing

    .PARAMETER Policy
    The password policy resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/password-api#/Password%20Policy/delete_authorize_identity_PasswordPolicy__id_

    .EXAMPLE
    Remove-PasswordPolicy (Get-Policy -Id "3c9ac645-b8c8-46c8-8781-a78e318e2e2d")

    .NOTES
    DELETE: /authorize/identity/PasswordPolicy/{id} v1
#>

function Remove-PasswordPolicy {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSObject]$Policy,

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
            Invoke-ApiRequest -Path "/authorize/identity/PasswordPolicy/$($Policy.id)" -Version 1 -Method Delete -Body $Policy -ValidStatusCodes @(204) | Out-Null
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}