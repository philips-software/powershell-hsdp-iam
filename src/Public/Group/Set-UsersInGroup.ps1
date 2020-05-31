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

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Org,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $GroupName,

        [Parameter(Mandatory, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [Array]
        $UserIds,

        [Parameter()]
        [switch]
        $Force
    )

    begin {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Function started"
        if (-not $PSBoundParameters.ContainsKey('Verbose')) {
            $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference')
        }
        if (-not $PSBoundParameters.ContainsKey('Confirm')) {
            $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference')
        }
        if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
            $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference')
        }
        Write-Verbose ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            $group = Get-Groups -Org $Org.id | Where-Object { $_.groupName -eq $GroupName }
            $UserIds | ForEach-Object {
                $user = Get-User -Id $_
                $membership = ($user.memberships | Where-Object { $_.organizationId -eq $Org.id -and $_.groups.Contains($GroupName) })
                if ($null -eq $membership) {
                    Write-Information "+adding user '$($user.loginId)' to group '$($GroupName)' in org '$($Org.id)' ('$($Org.name)')"
                    Set-GroupMember -Group $group -User $user
                } else {
                    Write-Information "# skipping user '$($user.loginId)' : already member of group '$($GroupName)' in org '$($Org.id) ('$($Org.name)')'"
                }
            }
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}