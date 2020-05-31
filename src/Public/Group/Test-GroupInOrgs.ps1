<#
    .SYNOPSIS
    Tests if a group exists in an org

    .DESCRIPTION
    This cmdlet is a utility to support checking if a a particular group by name exists in a set of organizations

    .OUTPUTS
    An array of orgs that do not contain the group

    .PARAMETER OrgIds
    An array of the organization identifiers

    .PARAMETER GroupName
    The group name to check in each organization

    .EXAMPLE
    $orgsWithOutGroup = Test-GroupInOrgs -OrgIds @(...) -GroupName "My Group")
#>
function Test-GroupInOrgs  {

    [CmdletBinding()]
    [OutputType([string[]])]
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
        $orgsWithOutGroup = @()

        $orgs = Get-Orgs | Where-Object { $OrgIds.Contains( $_.id) }

        $orgs | ForEach-Object {
            $group = (Get-Groups -OrgId $_.id) | Where-Object { $_.groupName -eq $GroupName }
            if (-not $group) {
                $orgsWithOutGroup.Add($_.id)
                Write-Warning "'$($_.id)' ($($_.name)) org does not have a group named '$($GroupName)'"
            }
        }
        Write-Output $orgsWithOutGroup
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}