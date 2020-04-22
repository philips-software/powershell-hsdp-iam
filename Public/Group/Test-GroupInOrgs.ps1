<#
    .SYNOPSIS
    Tests if a group exists in an org

    .DESCRIPTION
    This cmdlet is a utility to support checking if a a particular group by name exists in a set of organizations

    .PARAMETER OrgIds
    An array of the organization identifiers

    .PARAMETER GroupName
    The group name to check in each organization

    .EXAMPLE
    if (Test-GroupInOrgs -OrgIds @(...) -GroupName "My Group") {
        Write-Information "all orgs contain a 'My Group' group"
    }    
#>
function Test-GroupInOrgs  {

    [CmdletBinding()]
    [OutputType([boolean])]
    param(
        [ValidateNotNullOrEmpty()]
        [array]$OrgIds,

        [ValidateNotNullOrEmpty()]
        [string]$GroupName        
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"
        $valid = $true
        
        $orgs = Get-Orgs | Where-Object { $OrgIds.Contains( $_.id) }

        $orgs | ForEach-Object {
            $group = (Get-Groups -OrgId $_.id) | Where-Object { $_.groupName -eq $GroupName }
            if (-not $group) {
                Write-Warning "'$($_.id)' ($($_.name)) org does not have a group named '$($GroupName)'"
                $valid = $false
            }
        }        
        Write-Output $valid    
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}