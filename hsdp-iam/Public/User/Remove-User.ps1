<#
    .SYNOPSIS
    Remove a user account

    .DESCRIPTION
    Removes a user account from an organization. Any user with USER.DELETE or USER.WRITE permission
    can do this operation. Users can also delete their own accounts without these permissions.
    For this operation to be successful, the user should not have any memberships attached to it.

    .INPUTS
    An user resource object

    .PARAMETER User
    The user resource object to remove

    .EXAMPLE
    Remove-User -User $user

    .EXAMPLE
    Get-UserIds | Get-User | Where-Object {$_.loginId.StartsWith('test')} | Remove-User

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api-v2#/User%20Identity/delete_authorize_identity_User__id_

    .NOTES
    DELETE: /authorize/identity/User v2
#>
function Remove-User {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
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
            Write-Output @(Invoke-ApiRequest -Path "/authorize/identity/User/$($User.id)" -Version 2 -Method Delete -ValidStatusCodes @(204))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}