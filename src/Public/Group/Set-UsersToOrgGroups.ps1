<#
    .SYNOPSIS
    Add mutiple users to an existing group using names and ids strings

    .DESCRIPTION
    This cmdlet is a utility to support batch assigns users to a group when only ids are available

    .PARAMETER OrgIds
    An array of the organization identifiers

    .PARAMETER UserIds
    An array of user ids to assign to the group

    .PARAMETER GroupName
    The group name to assign the users. This group must exist.

    .EXAMPLE
    Set-UsersToOrgGroups -OrgIds @(...) -UserIds @(...) -GroupName "My Group"
    
    .NOTES    
    Users that are already memebers of the group will be skipped
#>
function Set-UsersToOrgGroups {
   
    [CmdletBinding()]
    param(   
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [array]
        $OrgIds,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [array]
        $UserIds,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [string]
        $GroupName

    )
     
    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
     
        Write-Information "Testing orgs"
        $invalidOrgs = Test-OrgIds $OrgIds

        Write-Information "Testing users"
        $invalidUsers = Test-UserIds $UserIds

        Write-Information "Testing groups"
        # Just write warnings. do not use result
        Test-GroupInOrgs -OrgIds $OrgIds -GroupName $GroupName
        
        if ($invalidOrgs.Count -gt 0 -or $invalidUsers.Count -gt 0) {
            $ErrorActionPreference = "Stop"
            Write-Error "Unable to continue -- Check warnings"
        }
        
        Get-Orgs | Where-Object { $orgIds.Contains( $_.id) } | ForEach-Object {
            Set-UsersInGroup -Org $_ -GroupName $GroupName -UserIds $UserIds
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }   
}