<#
    .SYNOPSIS
    Assign a role to a group

    .DESCRIPTION
    Assigns a role to a Group that, in turn, provides the corresponding role permissions to all the users underneath that Group.
    The role must be a registered role in the HSDP platform within the requester's Organization. To retrieve all registered Roles
    in an organization, refer to the Role management API.

    Note: Roles can be assigned to a Group one at a time. The maximum number of roles that can be assigned to a group is 10.

    .INPUTS
    Accepts the group object

    .OUTPUTS
    The updated group object. Must use this object for subsequent requests to meta.version is correct.

    .PARAMETER Group
    The group object 

    .PARAMETER Role
    The role object 

    .EXAMPLE
    $group = $group | Set-GroupRole $role

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___assign_role

    .NOTES
    POST: /authorize/identity/Group/{id}/$assign-role v1
#>
function Set-GroupRole {

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
        $path = "/authorize/identity/Group/$($Group.id)/`$assign-role"
        $response = (Invoke-ApiRequest -Path $path -Method Post -Body $body -ValidStatusCodes @(200))
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}