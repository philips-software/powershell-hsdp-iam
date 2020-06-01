<#
    .SYNOPSIS
    Remove user from a group

    .DESCRIPTION
    Given HSDP resource(s) shall be removed as members of the Group.

    .INPUTS
    Accepts the group object

    .OUTPUTS
    The updated group object. Must use this object for subsequent requests to meta.version is correct.

    .PARAMETER Group
    The group object

    .PARAMETER User
    The user object

    .EXAMPLE
    $group = Remove-GroupMember -Group $group -User $user

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___remove_members

    .NOTES
    POST: /authorize/identity/Group/{id}/$remove-members v1
#>
function Remove-GroupMember {

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

            $path = "/authorize/identity/Group/$($Group.id)/`$remove-members"
            $response = (Invoke-ApiRequest -Path $path -Method Post -Version 1 -Body $body -ValidStatusCodes @(200))

            # update the group version
            $group.meta.version = $response.meta.version

            Write-Output $response
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}