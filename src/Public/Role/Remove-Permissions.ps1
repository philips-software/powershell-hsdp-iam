<#
    .SYNOPSIS
    Remove permission(s) from a role.

    .DESCRIPTION
    Removes permission(s) from a role. The operation will fail if the permission(s) are not the
    assigned ones for the requested role.
    Note: A maximum of 10 permissions can be removed per request.
    
    .INPUTS
    A role PSObject

    .OUTPUTS
    An Operation Outcome PSObject

    .PARAMETER Role
    A role PSObject

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

    [CmdletBinding()]
    [OutputType([PSObject])]
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
        
        $body = @{ "permissions"= $Permissions; }

        $response  = (Invoke-ApiRequest -Path "/authorize/identity/Role/$($Role.id)/`$remove-permission" -Version 1 -Method Post -Body $body -ValidStatusCodes @(200,207))
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}