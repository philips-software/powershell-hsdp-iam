<#
    .SYNOPSIS
    Assign a role to a group

    .DESCRIPTION
    Assigns a role to a Group that, in turn, provides the corresponding role permissions to all the users underneath that Group.
    The role must be a registered role in the HSDP platform within the requester's Organization. To retrieve all registered Roles
    in an organization, refer to the Role management API.

    Note: Roles can be assigned to a Group one at a time. The maximum number of roles that can be assigned to a group is 100.

    .INPUTS
    Accepts the group resource object

    .OUTPUTS
    The updated group resource object. This object must be used for subsequent requests for the use of an updated meta.version.

    .PARAMETER Group
    The group resource object

    .PARAMETER Roles
    Any array of Role resource object to assign to the group.

    .EXAMPLE
    $group = $group | Set-GroupRole $role

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___assign_role

    .NOTES
    POST: /authorize/identity/Group/{id}/$assign-role v1
#>
function Set-GroupRole {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Group,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Roles,

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
            if ($Roles.Length -gt 100) {
                throw "Maximum number of roles per request is 100"
            }
            $RoleIds = $Roles | Select-Object Id
            $body = @{ "roles" = @($RoleIds) }
            $path = "/authorize/identity/Group/$($Group.id)/`$assign-role"
            Write-Output @(Invoke-ApiRequest -Path $path -Method Post -Version 1 -Body $body -ValidStatusCodes @(200))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}