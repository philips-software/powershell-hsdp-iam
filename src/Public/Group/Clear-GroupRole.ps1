<#
    .SYNOPSIS
    Remove a role from a group

    .DESCRIPTION
    Removes a role to a Group that, in turn, would revoke the corresponding role permissions to all the users underneath
    that Group. The role must be a registered role in the HSDP platform. To retrieve all assigned roles for a Group,
    refer to the Role management API. Roles can be removed from a Group one at a time.

    .INPUTS
    Accepts the group resource object to remove the role

    .OUTPUTS
    An operation outcome in PSObject form

    .PARAMETER Group
    The HSDP group resource object to clear the role

    .PARAMETER Role
    The HSDP role resource object to remove from the group

    .EXAMPLE
    $group | Clear-GroupRole $role

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___remove_role

    .NOTES
    POST: /authorize/identity/Group/{id}/$remove-role v1
#>
function Clear-GroupRole {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Group,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Role
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        # API documents show that it can support multiple roles assigned but only one is supported.
        $body = @{ "roles" = @($Role.id) }
        $path = "/authorize/identity/Group/$($Group.id)/`$remove-role"
        $response = (Invoke-ApiRequest -Path $path -Version 1 -Method Post -Body $body -ValidStatusCodes @(200))
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}