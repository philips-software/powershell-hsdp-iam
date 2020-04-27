<#
    .SYNOPSIS
    Retrieves Group(s) based on a set of parameters.

    .DESCRIPTION
    Retrieves one or more Group resources found under a given parent Organization and matches given search parameters. 
    A user with GROUP.READ will be allowed to retrieve groups from an organization. For query by memberId of an identity 
    that is assigned across organizations (such as SERVICE), this API retrieves all groups assigned to the identity irrespective 
    of organization

    .INPUTS
    Accepts the group identifier

    .OUTPUTS
    A HSDP group object

    .PARAMETER Id
    The group identifier

    .EXAMPLE
    $org = Get-Orgs | select-object -first 1
    $id = Get-Groups -OrgId $org.id | Select-Object -First 1 -ExpandProperty _id 
    $group = $id | Get-Group

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/get_authorize_identity_Group__id_

    .NOTES
    GET: /authorize/identity/Group/{id} v1
#>
function Get-Group {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [String]$Id
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $response = (Invoke-GetRequest "/authorize/identity/Group/$($Id)" -Version 1)
        $group = @($response)
        # experimental: add methods to this object to call related HSDP cmdlets
        $group | Add-Member -MemberType ScriptMethod -Name "Assign" -Value { param($Ids) $this | Set-GroupIdentity -Ids $Ids }
        $group | Add-Member -MemberType ScriptMethod -Name "Remove" -Value { param($Ids) $this | Remove-GroupIdentity -Ids $Ids }
        $group | Add-Member -MemberType ScriptMethod -Name "AddRole" -Value { param($Role) $this | Set-GroupRole -Role $Role }
        $group | Add-Member -MemberType ScriptMethod -Name "RemoveRole" -Value { param($Role) $this | Remove-GroupRole -Role $Role }
        $group | Add-Member -MemberType ScriptMethod -Name "AddMember" -Value { param($User) $this | Add-GroupMember -User $User }
        $group | Add-Member -MemberType ScriptMethod -Name "RemoveMember" -Value { param($User) $this | Remove-GroupMember -User $User }

        Write-Output $group
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}