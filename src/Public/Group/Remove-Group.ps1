<#
    .SYNOPSIS
    Deletes a Group.

    .DESCRIPTION
    Deletes a Group. This operation is only allowed when there are no members in the group.

    .INPUTS
    Accepts the group object

    .OUTPUTS
    An operation outcome in PSObject form

    .PARAMETER Group
    The group object 

    .EXAMPLE
    Get-Groups -OrgId $org.id | Select-Object -First 1 | Remove-Group

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/delete_authorize_identity_Group__id_

    .NOTES
    DELETE: /authorize/identity/Group/{id} v1
#>
function Remove-Group {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Group,
        
        [Switch]
        $Force
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        if ($Force) {
            # TODO: Remove associated User, Roles, and Services
        }
        Write-Output @(Invoke-ApiRequest -Path "/authorize/identity/Group/$($Group.id)" -Version 1 -Method Delete -ValidStatusCodes @(204))
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}