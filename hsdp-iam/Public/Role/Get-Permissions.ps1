<#
    .SYNOPSIS
    Returns a set of permission definitions.

    .DESCRIPTION
    This cmdlet returns a set of registered permission definitions based on query filters.

    .INPUTS
    A role resource object

    .OUTPUTS
    An array of permission resource objects

    .PARAMETER Role
    A role resource object

    .EXAMPLE
    $permissions = Get-Permissions -Role $role

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/role-api#/Role%20Management/List%20Permissions

    .NOTES
    GET: /authorize/identity/Permission v1
#>
function Get-Permissions {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Role
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output @((Invoke-GetRequest "/authorize/identity/Permission?roleId=$($Role.id)" -Version 1 -ValidStatusCodes @(200)).entry)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}