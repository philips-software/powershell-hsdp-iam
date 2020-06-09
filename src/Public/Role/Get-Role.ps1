<#
    .SYNOPSIS
    Get a requested role definition

    .DESCRIPTION
    This API returns a registered role given the role ID.

    .INPUTS
    A role identifier

    .OUTPUTS
    A role resource object

    .PARAMETER Id
    A role identifier

    .EXAMPLE
    $role = Get-Role "b41b992a-fb96-475e-90dd-ee3234362ca7"

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/role-api#/Role%20Management/Get%20Role

    .NOTES
    GET: /authorize/identity/Role/{id} v1
#>
function Get-Role {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 1, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [String]$Id
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        Write-Output (Invoke-GetRequest -Version 1 -Path "/authorize/identity/Role/$($Id)" -ValidStatusCodes @(200))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}