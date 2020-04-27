<#
    .SYNOPSIS
    Add mutiple users to a group using ids

    .DESCRIPTION
    This cmdlet batch assigns users by identifier to a group

    .INPUTS
    Accepts the organization object

    .OUTPUTS
    The updated group object. Must use this object for subsequent requests to meta.version is correct.

    .PARAMETER Org
    The organization object 

    .PARAMETER GroupName
    The name of the group to assign users

    .PARAMETER UserIds
    An array of user ids to assign to the group

    .EXAMPLE
    $org | Set-UsersInGroup -GroupName "My Group" -UserIds @("4eed47ac-1abd-462a-b3bf-f604f2b628cb")
    
    .NOTES    
    users that are already memebers of the group will be skipped
#>
function Set-UsersInGroup {

    [CmdletBinding()]
    [OutputType([PSObject])]
    param(   
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $Org,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [array]
        $UserIds
    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        
        $groups = Get-Groups -Org $Org.id
        $group = $groups | Where-Object { $_.groupName -eq $GroupName }
        $UserIds | ForEach-Object {
            $user = Get-User $_
            $membership = ($user.memberships | Where-Object { $_.organizationId -eq $Org.id -and $_.groups.Contains($GroupName) })        
            if (-not $membership) {            
                Write-Information "+adding user '$($user.loginId)' to group '$($GroupName)' in org '$($Org.id)' ('$($Org.name)')"
                Set-GroupMember -Group $group -User $user
            }
            else {
                Write-Information "# skipping user '$($user.loginId)' : already member of group '$($GroupName)' in org '$($Org.id)' ('$($Org.name)')"
            }        
        }        
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}