<#
    .SYNOPSIS
    Delete a user account

    .DESCRIPTION
    Removes a user account from an organization. Any user with USER.DELETE or USER.WRITE permission 
    can do this operation. Users can also delete their own accounts without these permissions. 
    For this operation to be successful, the user should not have any memberships attached to it.

    .INPUTS
    An user PSObject

    .PARAMETER User
    The user object to remove

    .EXAMPLE    
    Remove-User -User $user

    .EXAMPLE
    Get-Users -Org $org | Get-User | Where-Object {$_.loginId.StartsWith('test')} | Remove-User

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api-v2#/User%20Identity/delete_authorize_identity_User__id_

    .NOTES
    DELETE: /authorize/identity/User v2
#>
function Remove-User {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$User
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $response  = (Invoke-ApiRequest -Path "/authorize/identity/User/$($User.id)" -Version 2 -Method Delete -ValidStatusCodes @(204))
        Write-Output @($response)
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}