<#
    .SYNOPSIS
    Assign identity to a group

    .DESCRIPTION
    Assigns an identity to a Group. Assignment operation will provide all privileges that are associated with the group to assigned members.
    A user with GROUP.WRITE permission will be allowed to do this operation.

    Supported member types are - DEVICE, SERVICE
    Note: Maximum of 10 members can be assigned using this resource in one call.

    .INPUTS
    Accepts the group resource object

    .OUTPUTS
    The updated group resource object. This object must be used for subsequent requests for the use of an updated meta.version.

    .PARAMETER Group
    The group resource object

    .PARAMETER Ids
    An array of identifiers to add to the group

    .PARAMETER MemberType
    The member type of either "SERVICE" or "DEVICE". Defaults to "SERVICE"

    .EXAMPLE
    $group = Get-Group -Id "6ec094e1-73bf-4cfc-9a4e-5a17b577a3d1"
    $group = Set-GroupIdentity -Group $group -Ids @("1e9789bc-7267-4e94-9745-a3457adfd225")

    .LINK
    https://www.hsdp.io/documentation/identity-and-access-management-iam/api-documents/resource-reference-api/user-api/group-api#/Group%20Management/post_authorize_identity_Group__id___assign

    .NOTES
    POST: /authorize/identity/Group/{id}/$assign v1
#>
function Set-GroupIdentity {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    [OutputType([PSObject])]
    param(
        [Parameter(Mandatory, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [PSObject]
        $Group,

        [Parameter(Mandatory, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Array]
        $Ids,

        [Parameter(Position = 2)]
        [ValidateSet("SERVICE", "DEVICE")]
        [String]
        $MemberType = "SERVICE",

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
                "memberType" = $MemberType;
                "value"      = $Ids;
            }
            $path = "/authorize/identity/Group/$($Group.id)/`$assign"

            $response = (Invoke-ApiRequest -AdditionalHeaders @{"If-Match" =$Group.meta.version[0] } -Path $path -Version 1 -Method Post -Body $body -ValidStatusCodes @(200))

            # update the group version
            $group.meta.version = $response.meta.version

            Write-Output $response
        }
    }

    end {
        Write-Verbose "[$($MyInvocation.MyCommand.Name)] Complete"
    }
}