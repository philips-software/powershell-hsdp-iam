<#
    .SYNOPSIS
    Add one or more HSDP resource to a given group.

    .DESCRIPTION
    Given HSDP resource(s) shall be made members of the Group resource. An HSDP resource shall be identified by the relative
    reference in the system. In this release, the following behavior are denied (overview):

    1. Any duplicate entries in the input shall be considered only once.
    2. If the resource is already part of the destination group, then that resource shall be skipped.
    3. Resource reference (non-existing resources) shall be skipped and the output shall contain the list of such skipped resources.
    4. Add members operation doesn't support transaction.

    .INPUTS
    Accepts the group object

    .OUTPUTS
    The updated group object. Must use this object for subsequent requests to meta.version is correct.

    .PARAMETER Group
    The group object

    .PARAMETER User
    The user object

    .EXAMPLE
    Set-GroupMember -Group $group -User $user

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___add_members

    .NOTES
    POST: /authorize/identity/Group/{id}/$add-members v1
#>
function Set-GroupMember {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Group,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $User,

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
    }

    process {
        Write-Debug "[$($MyInvocation.MyCommand.Name)] PSBoundParameters: $($PSBoundParameters | Out-String)"

        if ($Force -or $PSCmdlet.ShouldProcess("ShouldProcess?")) {
            $ConfirmPreference = 'None'
            $body = @{
                "resourceType" = "Parameters"
                "parameter"    = @(
                    @{
                        "name"       = "UserIDCollection"
                        "references" = @(
                            @{ "reference" = $User.id }
                        )

                    })
            }
            Write-Output (Invoke-ApiRequest -Path "/authorize/identity/Group/$($Group.Id)/`$add-members" -Method Post -Version 1 -Body $body -ValidStatusCodes @(200))
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}