<#
    .SYNOPSIS
    Assign permission(s) to a role.

    .DESCRIPTION
    Assigns permission(s) to a role. The permission(s) passed in the request should be a valid registered
    one in the platform. If any permission passed for assignment is unknown, the request will fail.
    User can retrieve all registered permissions in the platform using the GET /authorize/identity/Permission API.

    Note: A maximum of 10 permissions can be assigned per request. A maximum of 100 permissions can be assigned to a role.

    .INPUTS
    A role PSObject

    .OUTPUTS
    An Operation Outcome PSObject

    .PARAMETER Role
    A role PSObject

    .PARAMETER Permissions
    An array of Permission names

    .EXAMPLE
    $role | Add-Permissions @("PATIENT.READ", "PATIENT.WRITE")

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/role-api#/Role%20Management/post_authorize_identity_Role__id___assign_permission

    .NOTES
    POST: /authorize/identity/Role/{id}}/$assign-permission v1
#>
function Add-Permissions {

    [CmdletBinding()]
    [OutputType([psobject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Role,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Permissions
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $body = @{ "permissions" = $Permissions; }
        $response = (Invoke-ApiRequest -Path "/authorize/identity/Role/$($Role.Id)/`$assign-permission" -Version 1 -Method Post -Body $body -ValidStatusCodes @(200))
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}