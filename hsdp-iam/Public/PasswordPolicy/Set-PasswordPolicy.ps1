<#
    .SYNOPSIS
    Updates a password policy

    .DESCRIPTION
    Updates a password policy from an organization. Any user with PASSWORDPOLICY.WRITE permission can update the policy.

    .INPUTS
    The updated policy object

    .OUTPUTS
    The new policy object

    .PARAMETER Policy
    The password policy resource object

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/password-api#/Password%20Policy/put_authorize_identity_PasswordPolicy__id_

    .EXAMPLE

    .NOTES
    PUT: /authorize/identity/PasswordPolicy v1
#>

function Set-PasswordPolicy {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [CmdletBinding()]
    [OutputType([PSObject])]
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
            Write-Output (Invoke-ApiRequest -Path "/authorize/identity/PasswordPolicy/$($Policy.id)" -Version 1 -Method Put -Body $Policy -AddIfMatch -ValidStatusCodes @(200) )
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}