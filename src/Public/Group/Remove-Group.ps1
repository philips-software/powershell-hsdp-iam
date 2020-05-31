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

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]$Group,

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
            Write-Output @(Invoke-ApiRequest -Path "/authorize/identity/Group/$($Group.id)" -Version 1 -Method Delete -ValidStatusCodes @(204))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}