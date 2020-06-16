<#
    .SYNOPSIS
    Remove permission(s) from a role.

    .DESCRIPTION
    Removes permission(s) from a role. The operation will fail if the permission(s) are not the
    assigned ones for the requested role.
    Note: A maximum of 100 permissions can be removed per request.

    .INPUTS
    A role resource object

    .OUTPUTS
    An Operation Outcome PSObject

    .PARAMETER Role
    A role resource object

    .PARAMETER Permissions
    An array of permission names

    .EXAMPLE
    $role | Remove-Permissions @("PATIENT.READ", "PATIENT.WRITE")

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/role-api#/Role%20Management/post_authorize_identity_Role__id___remove_permission

    .NOTES
    POST: /authorize/identity/Role/{id}}/$remove-permission v1
#>
function Remove-Permissions {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Role,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Permissions,

        [Parameter()]
        [Switch]
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
            if ($Permissions.Length -gt 100) {
                throw "Maximum number of permission per request is 100"
            }
            $body = @{ "permissions"= $Permissions; }
            $response  = (Invoke-ApiRequest -Path "/authorize/identity/Role/$($Role.id)/`$remove-permission" -Version 1 -Method Post -Body $body -ValidStatusCodes @(200))
            Write-Output @($response)
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}